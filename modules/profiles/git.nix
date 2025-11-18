s@{ config, pkgs, lib, self, ... }:
lib.mkProfile s "git"
{
  vaultix.secrets.caveman-token = { };
  vaultix.templates.github-caveman-conf = {
    owner = config.myos.user.mainUser;
    content = ''
      [url "https://${config.vaultix.placeholder.caveman-token}@github.com/sg-qwt/caveman"]
          insteadOf = https://github.com/sg-qwt/caveman
    '';
  };
  myhome = {
    programs.git = {
      enable = true;
      userName = "無名氏";
      userEmail = "hello@edgerunners.eu.org";

      signing = {
        signByDefault = false;
        format = "ssh";
        key = "key::${builtins.elemAt self.shared-data.openssh-keys 0}";
      };

      lfs.enable = true;

      extraConfig = {
        init.defaultBranch = "main";
        pull.rebase = true;
        push.followTags = true;
        push.autoSetupRemote = true;
        feature.manyFiles = true;
      };

      ignores = [ ".lsp/.cache" ".clj-kondo/.cache" ];

      includes = [
        { path = config.vaultix.templates.github-caveman-conf.path; }
      ];
    };
  };
}
