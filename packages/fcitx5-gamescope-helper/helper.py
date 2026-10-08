# SPDX-License-Identifier: MIT
"""Session-local workaround for Fcitx candidate popups in nested Gamescope."""

import argparse
import logging
import os
import signal
import subprocess
import time
from pathlib import Path

from Xlib import X, Xatom, display, error

LOG = logging.getLogger("fcitx5-gamescope-helper")
FCITX_CLASS = ("fcitx", "fcitx")
X_ERRORS = (error.XError, error.ConnectionClosedError, OSError)


def snapshot(window, atom):
    prop = window.get_full_property(atom, X.AnyPropertyType)
    if prop is None:
        return None
    value = bytes(prop.value) if prop.format == 8 else list(prop.value)
    return prop.property_type, prop.format, value


class PropertyEdit:
    """Restore a property only if nobody else has changed our last value."""

    def __init__(self, window, atom):
        self.window = window
        self.atom = atom
        self.original = snapshot(window, atom)
        self.written = self.original

    def apply(self, value):
        if snapshot(self.window, self.atom) != value:
            kind, bits, data = value
            self.window.change_property(self.atom, kind, bits, data)
        self.written = value

    def restore(self):
        if snapshot(self.window, self.atom) != self.written:
            return
        if self.original is None:
            self.window.delete_property(self.atom)
        else:
            kind, bits, data = self.original
            self.window.change_property(self.atom, kind, bits, data)


def merge_dpi(resources, dpi):
    lines = resources.splitlines(keepends=True)
    data = b"".join(
        line for line in lines if line.split(b":", 1)[0].strip() != b"Xft.dpi"
    )
    if data and not data.endswith(b"\n"):
        data += b"\n"
    return data + f"Xft.dpi:\t{dpi}\n".encode()


class NotGamescope(Exception):
    pass


class GamescopeDisplay:
    def __init__(self, name, dpi):
        self.name = name
        self.connection = display.Display(name)
        self.popups = {}
        self.dpi_edit = None
        self.closed = False
        try:
            self.root = self.connection.screen().root
            self.atoms = {
                name: self.connection.intern_atom(name)
                for name in (
                    "GAMESCOPE_PID",
                    "_NET_ACTIVE_WINDOW",
                    "STEAM_GAME",
                    "WM_TRANSIENT_FOR",
                )
            }
            pid = snapshot(self.root, self.atoms["GAMESCOPE_PID"])
            if (
                pid is None
                or pid[0:2] != (Xatom.CARDINAL, 32)
                or not pid[2]
                or pid[2][0] <= 0
            ):
                raise NotGamescope(name)
            self.dpi_edit = PropertyEdit(self.root, Xatom.RESOURCE_MANAGER)
            old = self.dpi_edit.original
            if old is not None and old[0:2] != (Xatom.STRING, 8):
                raise ValueError(f"Unexpected RESOURCE_MANAGER format on {name}")
            data = merge_dpi(old[2] if old is not None else b"", dpi)
            self.dpi_edit.apply((Xatom.STRING, 8, data))
            self.connection.sync()
            self.next_connect = 0
            self.connect_failed = False
            LOG.info("Discovered Gamescope %s; candidate DPI %s", name, dpi)
        except Exception:
            self.close()
            raise

    def connect_fcitx(self):
        if time.monotonic() < self.next_connect:
            return
        self.next_connect = time.monotonic() + 5
        try:
            # --check prevents this helper from starting a second Fcitx daemon.
            result = subprocess.run(
                ["fcitx5-remote", "--check", "-x"],
                env=dict(os.environ, DISPLAY=self.name),
                capture_output=True,
                text=True,
                timeout=3,
                check=False,
            )
            if result.returncode:
                if not self.connect_failed:
                    LOG.warning(
                        "Fcitx connection to %s pending: %s",
                        self.name,
                        result.stderr.strip(),
                    )
                self.connect_failed = True
            elif self.connect_failed:
                LOG.info("Fcitx connected to %s", self.name)
                self.connect_failed = False
        except (OSError, subprocess.TimeoutExpired) as exc:
            if not self.connect_failed:
                LOG.warning("Fcitx connection to %s pending: %s", self.name, exc)
            self.connect_failed = True

    def update(self):
        self.connect_fcitx()
        windows = self.root.query_tree().children
        live = {w.id for w in windows}
        for wid in list(self.popups):
            if wid not in live:
                del self.popups[wid]

        active = snapshot(self.root, self.atoms["_NET_ACTIVE_WINDOW"])
        if active is None or active[0:2] != (Xatom.WINDOW, 32) or not active[2]:
            return
        owner = next((w for w in windows if w.id == active[2][0]), None)
        if owner is None or owner.get_wm_class() == FCITX_CLASS:
            return
        app = snapshot(owner, self.atoms["STEAM_GAME"])
        if app is None or app[0:2] != (Xatom.CARDINAL, 32) or not app[2]:
            return

        for window in windows:
            try:
                if (
                    window.get_wm_class() != FCITX_CLASS
                    or window.get_wm_name() != "Fcitx5 Input Window"
                    or not window.get_attributes().override_redirect
                ):
                    continue
                edits = self.popups.get(window.id)
                if edits is None:
                    edits = (
                        PropertyEdit(window, self.atoms["WM_TRANSIENT_FOR"]),
                        PropertyEdit(window, self.atoms["STEAM_GAME"]),
                    )
                    self.popups[window.id] = edits
                parent = (Xatom.WINDOW, 32, [owner.id])
                app_value = (Xatom.CARDINAL, 32, [app[2][0]])
                changed = edits[0].written != parent or edits[1].written != app_value
                edits[0].apply(parent)
                edits[1].apply(app_value)
                if changed:
                    LOG.info(
                        "%s popup %#x -> owner %#x, app %s",
                        self.name,
                        window.id,
                        owner.id,
                        app[2][0],
                    )
            except error.BadWindow:
                # Fcitx or the game may destroy a window during enumeration.
                self.popups.pop(window.id, None)
        self.connection.sync()

    def close(self, restore=True):
        if self.closed:
            return
        self.closed = True
        if restore:
            for edits in self.popups.values():
                for edit in edits:
                    try:
                        edit.restore()
                    except X_ERRORS:
                        pass
            if self.dpi_edit is not None:
                try:
                    self.dpi_edit.restore()
                except X_ERRORS:
                    pass
            try:
                self.connection.sync()
            except X_ERRORS:
                pass
        try:
            self.connection.close()
        except X_ERRORS:
            # Xlib close() flushes first and raises if the server disconnected.
            # Its disconnect handler has already closed the underlying socket.
            pass


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--dpi", type=int, default=192, help="DPI for Gamescope displays (default: 192)"
    )
    args = parser.parse_args()
    if args.dpi <= 0:
        parser.error("--dpi must be positive")
    logging.basicConfig(level=logging.INFO, format="%(levelname)s: %(message)s")
    stopped = False

    def stop(_signal, _frame):
        nonlocal stopped
        stopped = True

    signal.signal(signal.SIGTERM, stop)
    signal.signal(signal.SIGINT, stop)
    connections = {}
    next_scan = 0
    try:
        while not stopped:
            if time.monotonic() >= next_scan:
                next_scan = time.monotonic() + 5
                for socket in Path("/tmp/.X11-unix").glob("X[0-9]*"):
                    if not socket.name[1:].isdigit():
                        continue
                    name = ":" + socket.name[1:]
                    if name in connections:
                        continue
                    try:
                        connections[name] = GamescopeDisplay(name, args.dpi)
                    except (NotGamescope, error.DisplayConnectionError):
                        pass
                    except (*X_ERRORS, ValueError) as exc:
                        LOG.warning("Cannot initialize %s: %s", name, exc)
            for name, connection in list(connections.items()):
                try:
                    connection.update()
                except error.BadWindow:
                    # A game can disappear between reading its ID and properties.
                    continue
                except X_ERRORS as exc:
                    LOG.info("Display %s closed/unavailable: %s", name, exc)
                    # The server is gone; its properties no longer exist to restore.
                    connection.close(restore=False)
                    del connections[name]
            time.sleep(0.25)
    finally:
        for connection in connections.values():
            connection.close()


if __name__ == "__main__":
    main()
