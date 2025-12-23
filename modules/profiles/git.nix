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

      signing = {
        signByDefault = false;
        format = "ssh";
        key = "key::${builtins.elemAt self.shared-data.openssh-keys 0}";
      };

      lfs = {
        enable = true;
      };

      settings = {
        user = {
          name = "無名氏";
          email = "hello@edgerunners.eu.org";
        };
        init.defaultBranch = "main";
        pull.rebase = true;
        push.followTags = true;
        push.autoSetupRemote = true;
        feature.manyFiles = true;
        lfs.ssh.automultiplex = false;
      };

      ignores = [ ".lsp/.cache" ".clj-kondo/.cache" ];

      includes = [
        { path = config.vaultix.templates.github-caveman-conf.path; }
      ];
    };
  };
}
