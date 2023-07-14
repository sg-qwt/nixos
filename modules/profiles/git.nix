s@{ config, pkgs, lib, ... }:
lib.mkProfile s "git"
{
  home-manager.users."${config.myos.users.mainUser}" = {
    programs.git = {
      enable = true;
      userName = "無名氏";
      userEmail = "hello@edgerunners.eu.org";

      signing = {
        signByDefault = false;
        key = "77EEFB04BFD81826";
      };

      lfs.enable = false;

      extraConfig = {
        init.defaultBranch = "main";
        pull.rebase = true;
        push.followTags = true;
        push.autoSetupRemote = true;
        feature.manyFiles = true;
      };
    };
  };
}
