s@{ config, pkgs, lib, self, ... }:
lib.mkProfile s "qqqemacs"
  (
    let
      npx = lib.getExe' pkgs.nodejs "npx";
      # TODO proper build this npm
      brave-mcp = pkgs.writeShellScriptBin "brave-search-mcp" ''
        export PATH="${pkgs.nodejs}/bin:$PATH"
        exec ${npx} -y @brave/brave-search-mcp-server --brave-api-key "$(cat ${config.vaultix.secrets.brave-search-key.path})" "$@"
      '';
      gpt-host = "${self.shared-data.az-anu-domain}.openai.azure.com";
      json = pkgs.formats.json { };
      trafilatura = lib.getExe pkgs.python3Packages.trafilatura;
      brepl = lib.getExe pkgs.my.brepl;

      eca-config = json.generate "eca-config.json" {
        defaultBehavior = "agent";
        defaultModel = "azantro/claude-opus-4-5";
        netrcFile = config.vaultix.templates.eca-netrc.path;
        providers = {
          azure = {
            api = "openai-responses";
            url = "https://${gpt-host}";
            completionUrlRelativePath = "/openai/v1/responses";
            key = "\${netrc:${gpt-host}}";
            models = {
              gpt-5-mini = { };
            };
          };
          azantro = {
            api = "anthropic";
            url = "https://${gpt-host}/anthropic";
            key = "\${netrc:${gpt-host}}";
            models = {
              claude-opus-4-5 = { };
            };
          };
        };
        customTools = {
          brepl-eval = {
            description = ''
              Evaluates Clojure code using brepl. Returns the result of evaluation with stdout/stderr captured.

              The tool AUTOMATICALLY wraps your code in a safe heredoc pattern ('<<EOF'), so you must provide ONLY the raw Clojure code.
              Do not add the 'brepl' command or 'EOF' markers yourself.
              Ensure proper bracket balancing and valid syntax.
            '';
            command = "${brepl} \"$(cat <<'EOF'\n{{code}}\nEOF\n)\"";
            schema = {
              properties = {
                code = {
                  type = "string";
                  description = "The raw Clojure expression(s) to evaluate. Example: (require '[my.ns] :reload) (my.ns/func)";
                };
              };
              required = [ "code" ];
            };
          };
          brepl-load-file = {
            description = "Loads an entire Clojure file into the nREPL environment.";
            command = "${brepl} -f {{file}}";
            schema = {
              properties = {
                file = {
                  type = "string";
                  description = "The path to the file to load (e.g., 'src/myapp/core.clj').";
                };
              };
              required = [ "file" ];
            };
          };
          web-fetch = {
            description = "Fetches the content of a URL and returns it in Markdown format.";
            command = "${trafilatura} --output-format=markdown -u {{url}}";
            schema = {
              properties = {
                url = {
                  type = "string";
                  description = "The URL to fetch content from.";
                };
              };
              required = [
                "url"
              ];
            };
          };
        };
        mcpServers = {
          brave-search = {
            command = "${lib.getExe brave-mcp}";
            args = [ ];
          };
        };
      };

      my-eca = (pkgs.symlinkJoin {
        name = "myeca";
        paths = [ self.packages.${pkgs.system}.eca ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/eca \
            --add-flags "--config-file ${eca-config}"
        '';
      });

      eca-bin = lib.getExe' my-eca "eca";
    in
    {
      # sudo mkdir -p /var/cache/man/nixos
      # sudo mandb
      # this slows down builds
      # documentation.man.generateCaches = true; 

      vaultix.secrets.openai-key = { };
      vaultix.secrets.github-ai-pat = { };
      vaultix.templates.authinfo = {
        content = ''
          machine ${gpt-host} login apikey password ${config.vaultix.placeholder.openai-key}
        '';
        owner = config.myos.user.mainUser;
      };

      vaultix.secrets.eca-openai-key = {
        owner = config.myos.user.mainUser;
      };

      vaultix.secrets.brave-search-key = {
        owner = config.myos.user.mainUser;
      };

      myos.sdcv-with-dicts.enable = true;

      myos.langs = {
        clojure = true;
        rust = true;
      };

      vaultix.secrets.eca-openai-key = { };

      vaultix.templates.eca-netrc = {
        content = ''
          machine ${gpt-host}
          password ${config.vaultix.placeholder.eca-openai-key}
        '';
        owner = config.myos.user.mainUser;
      };

      environment = {
        systemPackages = [
          my-eca
          (pkgs.symlinkJoin {
            name = "qqqemacs";
            paths = [ self.packages.${pkgs.system}.qqqemacs ];
            nativeBuildInputs = [ pkgs.makeWrapper ];
            postBuild = ''
              wrapProgram $out/bin/emacs \
                --set QQQ_ECA_PATH ${eca-bin} \
                --set QQQ_AUTHINFO ${config.vaultix.templates.authinfo.path}
            '';
          })
        ];
      };

      myhome = { config, osConfig, ... }: {
        home.sessionVariables.EDITOR = "emacsclient -t";

        programs.bash.initExtra = ''

          if [[ "$INSIDE_EMACS" = 'vterm' ]]; then
            source ${pkgs.emacsPackages.vterm}/share/emacs/site-lisp/elpa/vterm-*/etc/emacs-vterm-bash.sh
          fi

        '';
      };
    }
  )

  
