s@{ config, pkgs, lib, self, ... }:
let
  git-credential-cavemen = pkgs.writeShellScript "git-credential-cavemen" ''
    # A credential helper receives the requested credential on stdin. Return
    # nothing for non-matching requests so Git can try another helper or prompt.
    if [ "$1" != "get" ]; then
      exit 0
    fi

    protocol=
    host=
    path=
    while IFS='=' read -r key value; do
      case "$key" in
        protocol) protocol="$value" ;;
        host) host="$value" ;;
        path) path="$value" ;;
      esac
    done

    if [ "$protocol" = "https" ] \
      && [ "$host" = "github.com" ] \
      && [ "$path" = "sg-qwt/caveman.git" ]; then
      printf '%s\n' \
        "username=pat" \
        "password=$(cat ${config.vaultix.secrets.caveman-token-new.path})" \
        ""
    fi
  '';
in
lib.mkProfile s "git"
{
  vaultix.secrets.caveman-token-new = {
    owner = config.myos.user.mainUser;
  };

  myhome = {
    programs.git = {
      enable = true;

      signing = {
        signByDefault = false;
        format = "ssh";
        key =
          if config.networking.hostName == "kirin" then
            "key::${builtins.elemAt self.shared-data.openssh-keys 0}"
          else
            "key::${builtins.elemAt self.shared-data.openssh-keys 1}";
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

        credential."https://github.com" = {
          useHttpPath = true;
          helper = "${git-credential-cavemen}";
        };
      };

      ignores = [ ".lsp/.cache" ".clj-kondo/.cache" ];
    };
  };
}
