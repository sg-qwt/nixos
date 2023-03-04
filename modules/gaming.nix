{ config, pkgs, lib, helpers, ... }:
helpers.mkModule config lib
  "gaming"
  "Steam and other stuff"
{
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
  };

  myos.protonge.enable = true;

  fonts.fonts = with pkgs; [
    wqy_microhei
    wqy_zenhei
    liberation_ttf
  ];

  # controller
  hardware.xone.enable = true;

  environment = {
    systemPackages = with pkgs; [
      # mangohud
      # my.ryujinx
      # (my.ryujinx.overrideAttrs (old: {
      #   buildInputs = old.buildInputs ++ [ pkgs.makeWrapper ];
      #   postInstall = old.postInstall or "" + ''
      #     wrapProgram $out/lib/ryujinx-vulkan/Ryujinx --set GDK_BACKEND x11
      #   '';
      # }))

      # ((my.yuzu.override { branch = "early-access"; }).overrideAttrs (old: {
      #   buildInputs = old.buildInputs ++ [ pkgs.makeWrapper ];
      #   postInstall = old.postInstall or "" + ''
      #     wrapProgram $out/bin/yuzu --set QT_QPA_PLATFORM xcb
      #   '';
      # }))

      # config.nur.repos.dukzcry.gamescope

      (pkgs.writeTextDir
        "share/applications/steam-tcp.desktop"
        (lib.generators.toINI { }
          {
            "Desktop Entry" = {
              Type = "Application";
              Exec = "steam -tcp";
              Terminal = false;
              Name = "Steam (tcp)";
              Icon = "steam";
              Categories = "Game;";
            };
          }))
    ];
  };

  home-manager.users."${config.myos.users.mainUser}" = { config, ... }: {
    xdg.configFile."MangoHud/MangoHud.conf".source = ../config/mangohud.conf;
  };
}
