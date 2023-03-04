{ pkgs }:
''
  swaySocket="''${XDG_RUNTIME_DIR:-/run/user/$UID}/sway-ipc.$UID.$(${pkgs.procps}/bin/pgrep --uid $UID -x sway || true).sock"
  if [ -S "$swaySocket" ]; then
      ${pkgs.sway}/bin/swaymsg -s $swaySocket reload
  fi
''
