s@{ config, pkgs, lib, ... }:
lib.mkProfile s "git"
{
  myhome = {
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

      ignores = [ ".lsp/.cache" ".clj-kondo/.cache" ];
    };
  };
}
