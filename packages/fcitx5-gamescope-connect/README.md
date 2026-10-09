# Fcitx Gamescope launch hook

A one-shot connector, called by Steam's `extraPreBwrapCmds` before entering its
FHS environment. When Steam starts inside Gamescope, Gamescope's `DISPLAY` and
all `STEAM_GAME_DISPLAY_<n>` variables are already available.

The hook deduplicates those display names and verifies each server's
`GAMESCOPE_PID`. It merges `Xft.dpi: 192` into each server's root X resources,
preserving unrelated entries. Existing `Xft.dpi` entries are replaced and an
unchanged resource value is not rewritten. DPI is applied even if Fcitx is already
connected; servers whose `@server=fcitx` selection has an owner skip registration.
Otherwise it calls `fcitx5-remote --check -x` with a three-second timeout. An
"already exists" race is harmless; other failures are logged but do not prevent
Steam from starting. `--check` avoids spawning a second Fcitx daemon.

`--dpi` accepts a positive integer (default: 192). The gaming profile explicitly
passes `--dpi 192` for 2x candidate scaling on its 4K Gamescope display. Changes
are logged, for example `INFO: Set :1 Xft.dpi to 192`.

Xft DPI is display-wide, so other X11 toolkits inside Gamescope may also use it.
The desktop display is never changed. No display numbers are hard-coded and there
is no background polling, popup-ownership workaround, or keyboard-focus
manipulation. Desktop Steam launches are unaffected. The X resources remain until
the Gamescope Xwayland server exits; no background cleanup is required.

The existing session Fcitx daemon must be running when Steam starts. This hook
does not recover connections if Fcitx restarts later or Gamescope adds servers
after launch; launch-time registration covers the configured two-server setup.
