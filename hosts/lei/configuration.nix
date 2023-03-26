# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, rootPath, ... }:

{
  # boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelPatches = [ ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.wireless.enable = false;
  networking.networkmanager.enable = true;

  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  hardware.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    pulse.enable = true;
  };

  systemd.services.thinkpad-fix-sound = {
    description = "Fix the sound on X1";
    path = [ pkgs.alsaTools ];
    wantedBy = [ "default.target" ];
    after = [ "sound.target" "alsa-store.service" ];
    script = ''
      ${pkgs.alsaTools}/bin/hda-verb /dev/snd/hwC0D0 0x1d SET_PIN_WIDGET_CONTROL 0x0
    '';
  };

  myos.common.enable = true;
  myos.desktop.enable = true;
  myos.users.enable = true;
  myos.fcitx.enable = true;
  myos.gnome.enable = true;
  myos.wayland.enable = true;

  myos.tmux.enable = true;
  myos.qqqemacs.enable = true;

  myos.alacritty.enable = true;
  myos.shell.enable = true;
  myos.git.enable = true;
  myos.ssh.enable = true;
  myos.gnupg.enable = true;
  myos.desktop-apps.enable = true;
  myos.clojure-dev.enable = true;
  myos.tools.enable = true;
  myos.theme.enable = true;

  myos.clash-meta.enable = true;

  services.blueman.enable = true;

  hardware.bluetooth = {
    enable = true;
    package = pkgs.bluez;
    settings = {
      General = {
        Experimental = true;
      };
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?

}
