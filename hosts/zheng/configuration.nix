# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, ... }:

{
  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostId = "a658e17d";

  services.pcscd.enable = true;

  myos.common.enable = true;
  myos.desktop.enable = true;
  myos.users = {
    enable = true;
    extraGroups = [ "input" ];
  };
  myos.shell.enable = true;
  myos.git.enable = true;
  myos.gnupg.enable = true;
  myos.tailscale.enable = true;

  # services.xserver = {
  #   enable = true;
  #   displayManager.lightdm = {
  #     enable = true;
  #     greeters.gtk.extraConfig = lib.mkAfter ''
  #       keyboard=${pkgs.onboard}/bin/onboard
  #       xft-dpi=256
  #       a11y-states=+keyboard
  #     '';
  #   };

  #   displayManager.defaultSession = "steam-wayland";
  #   displayManager.autoLogin.enable = true;
  #   displayManager.autoLogin.user = "${config.myos.users.mainUser}";
  # };

  services.xserver = {
    enable = true;
    libinput.enable = true;
    displayManager.startx.enable = true;
    desktopManager.plasma5.enable = true;
  };

  services.getty.autologinUser = "${config.myos.users.mainUser}";


  home-manager.users."${config.myos.users.mainUser}" = {
    home.file.".xinitrc".text = ''
      export DESKTOP_SESSION=plasma
      exec ${pkgs.libsForQt5.plasma-workspace}/bin/startplasma-x11
    '';
  };

  systemd.services.gamescope-switcher = {
    wantedBy = [ "graphical.target" ];
    serviceConfig = {
      User = 1000;
      PAMName = "login";
      WorkingDirectory = "~";

      TTYPath = "/dev/tty7";
      TTYReset = "yes";
      TTYVHangup = "yes";
      TTYVTDisallocate = "yes";

      StandardInput = "tty-fail";
      StandardOutput = "journal";
      StandardError = "journal";

      UtmpIdentifier = "tty7";
      UtmpMode = "user";

      Restart = "always";
    };

    script = ''
      set-session () {
        mkdir -p ~/.local/state
        >~/.local/state/steamos-session-select echo "$1"
      }
      consume-session () {
        if [[ -e ~/.local/state/steamos-session-select ]]; then
          cat ~/.local/state/steamos-session-select
          rm ~/.local/state/steamos-session-select
        else
          echo "gamescope"
        fi
      }
      while :; do
        session=$(consume-session)
        case "$session" in
          plasma)
            # FIXME: Replace with your favorite method
            >>~/gamescope.log echo "test start plasma"
            startx
            ;;
          gamescope)
            >>~/gamescope.log echo "test start steam"
            steam-session
            ;;
        esac
      done
    '';
  };



  hardware.pulseaudio.enable = false;
  jovian.devices.steamdeck.enable = true;
  jovian.steam.enable = true;
  myos.protonge.enable = true;

  hardware.bluetooth = {
    enable = true;
    package = pkgs.bluez;
    settings = {
      General = {
        Experimental = true;
      };
    };
  };

  environment.systemPackages = with pkgs; [
    steamdeck-firmware
    onboard
  ];

  programs.steam = {
    enable = true;
  };
}
