# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  # boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelPatches = [ ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
  };

  hardware.firmware = [ pkgs.sof-firmware ];
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
    extraPackages = [ pkgs.intel-media-driver ];
  };

  hardware.pulseaudio.enable = false;

  services.fwupd.enable = true;
  services.pipewire = {
    enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    pulse.enable = true;
  };

  systemd.services.thinkpad-fix-sound =
    let targets = [ "suspend.target" "hibernate.target" "hybrid-sleep.target" "suspend-then-hibernate.target" ]; in
    {
      description = "Fix the sound on X1";
      path = [ pkgs.alsaTools ];
      wantedBy = [ "sound.target" ] ++ targets;
      after = [ "sound.target" "graphical.target" "multi-user.target" ] ++ targets;
      script = ''
        hda-verb /dev/snd/hwC0D0 0x1d SET_PIN_WIDGET_CONTROL 0x0
      '';
    };

  myos.sway.enable = true;

  myos.desktop.enable = true;
  myos.fcitx.enable = true;

  myos.tmux.enable = true;
  myos.qqqemacs.enable = true;

  myos.shell.enable = true;
  myos.git.enable = true;
  myos.ssh.enable = true;
  myos.gnupg.enable = true;
  myos.desktop-apps.enable = true;
  myos.tools.enable = true;

  myos.clash-meta.enable = true;
  myos.tailscale.enable = true;

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
}
