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
        format = "ssh";
        key = "key::${builtins.elemAt config.myos.data.openssh-keys 0}";
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
