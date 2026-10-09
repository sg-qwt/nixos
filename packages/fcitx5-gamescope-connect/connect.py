# SPDX-License-Identifier: MIT
"""One-shot Fcitx registration and DPI setup for Gamescope Xwayland servers."""

import argparse
import logging
import os
import re
import subprocess

from Xlib import X, Xatom, display, error

LOG = logging.getLogger("fcitx5-gamescope-connect")
X_ERRORS = (
    error.XError,
    error.ConnectionClosedError,
    error.DisplayConnectionError,
    OSError,
)


def displays(env):
    keys = sorted(
        (key for key in env if re.fullmatch(r"STEAM_GAME_DISPLAY_[0-9]+", key)),
        key=lambda key: int(key.rsplit("_", 1)[1]),
    )
    return list(dict.fromkeys(env[key] for key in ["DISPLAY", *keys] if env.get(key)))


def merge_dpi(resources, dpi):
    lines = [
        line
        for line in resources.splitlines(keepends=True)
        if line.split(b":", 1)[0].strip() != b"Xft.dpi"
    ]
    data = b"".join(lines)
    if data and not data.endswith(b"\n"):
        data += b"\n"
    return data + f"Xft.dpi:\t{dpi}\n".encode()


def prepare_display(name, dpi):
    """Set display-local DPI, then return whether Fcitx needs a connection."""
    connection = display.Display(name)
    try:
        atom = connection.intern_atom("GAMESCOPE_PID", only_if_exists=True)
        if not atom:
            return False
        pid = connection.screen().root.get_full_property(atom, X.AnyPropertyType)
        if (
            pid is None
            or pid.property_type != Xatom.CARDINAL
            or pid.format != 32
            or not len(pid.value)
            or pid.value[0] <= 0
        ):
            return False
        root = connection.screen().root
        resources = root.get_full_property(Xatom.RESOURCE_MANAGER, X.AnyPropertyType)
        if resources is not None and (
            resources.property_type != Xatom.STRING or resources.format != 8
        ):
            LOG.warning("Leaving malformed X resources unchanged on %s", name)
        else:
            old = resources.value if resources is not None else b""
            new = merge_dpi(old, dpi)
            if old != new:
                root.change_property(Xatom.RESOURCE_MANAGER, Xatom.STRING, 8, new)
                connection.sync()
                LOG.info("Set %s Xft.dpi to %d", name, dpi)
        atom = connection.intern_atom("@server=fcitx", only_if_exists=True)
        owner = connection.get_selection_owner(atom) if atom else X.NONE
        return getattr(owner, "id", owner) == X.NONE
    finally:
        try:
            connection.close()
        except X_ERRORS:
            # Xlib's close() also flushes, even when the server has gone away.
            pass


def connect(name, dpi=192):
    try:
        if not prepare_display(name, dpi):
            return
        result = subprocess.run(
            ["fcitx5-remote", "--check", "-x"],
            env=dict(os.environ, DISPLAY=name),
            capture_output=True,
            text=True,
            timeout=3,
            check=False,
        )
        # A toolkit or another launcher may connect after our selection check.
        if "X11 connection already exists" in result.stderr:
            return
        if result.returncode:
            LOG.warning(
                "Cannot connect Fcitx to %s: %s",
                name,
                result.stderr.strip() or f"exit status {result.returncode}",
            )
        else:
            LOG.info("Connected Fcitx to %s", name)
    except (*X_ERRORS, subprocess.TimeoutExpired) as exc:
        # IME unavailability should not stop Steam from starting.
        LOG.warning("Cannot connect Fcitx to %s: %s", name, exc)


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--dpi", type=int, default=192, help="DPI for Gamescope displays (default: 192)"
    )
    args = parser.parse_args(argv)
    if args.dpi <= 0:
        parser.error("--dpi must be positive")
    logging.basicConfig(level=logging.INFO, format="%(levelname)s: %(message)s")
    if os.environ.get("GAMESCOPE_WAYLAND_DISPLAY"):
        for name in displays(os.environ):
            connect(name, args.dpi)


if __name__ == "__main__":
    main()
