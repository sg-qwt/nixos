{ config, pkgs, lib, helpers, ... }:
helpers.mkModule config lib "firefox" "firefox" {
  home-manager.users."${config.myos.users.mainUser}" = {

    programs.firefox = {
      enable = true;
      profiles = {
        windranger = {
          isDefault = true;
          extensions = with config.nur.repos.rycee.firefox-addons; [
            ublock-origin
            protondb-for-steam
            steam-database
            metamask
            notion-web-clipper
          ];
          settings = {
            "browser.aboutwelcome.enabled" = false;
            "browser.discovery.enabled" = false;
            "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons" =
              false;
            "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.features" =
              false;
            "browser.newtabpage.activity-stream.feeds.telemetry" = false;
            "browser.newtabpage.activity-stream.telemetry" = false;

            "signon.rememberSignons" = false;

            "browser.startup.homepage" = "about:blank";
            "browser.newtabpage.enabled" = false;

            "browser.pocket.enabled" = false;
            "extensions.pocket.enabled" = false;

            "datareporting.healthreport.uploadEnabled" = false;
            "datareporting.healthreport.service.enabled" = false;
            "datareporting.policy.dataSubmissionEnabled" = false;

            "signon.management.page.breach-alerts.enabled" = false;
            "browser.safebrowsing.malware.enabled" = false;
            "browser.safebrowsing.phishing.enabled" = false;
            "browser.safebrowsing.downloads.remote.enabled" = false;

            "app.normandy.enabled" = false;
            "app.normandy.api_url" = "";
            "extensions.shield-recipe-client.enabled" = false;
            "app.shield.optoutstudies.enabled" = false;

            "extensions.update.enabled" = false;
            "toolkit.telemetry.enabled" = false;
            "browser.ping-centre.telemetry" = false;
            "toolkit.telemetry.archive.enabled" = false;
            "toolkit.telemetry.bhrPing.enabled" = false;
            "toolkit.telemetry.firstShutdownPing.enabled" = false;
            "toolkit.telemetry.hybridContent.enabled" = false;
            "toolkit.telemetry.newProfilePing.enabled" = false;
            "toolkit.telemetry.reportingpolicy.firstRun" = false;
            "toolkit.telemetry.shutdownPingSender.enabled" = false;
            "toolkit.telemetry.unified" = false;
            "toolkit.telemetry.updatePing.enabled" = false;
            "toolkit.telemetry.pioneer-new-studies-available" = false;

            "experiments.supported" = false;
            "experiments.enabled" = false;
            "experiments.manifest.uri" = false;
            "network.allow-experiments" = false;
          };

          search = {
            force = true;

            default = "Google UK";

            engines = {
              "Google".metaData.hidden = true;
              "Wikipedia (en)".metaData.alias = "@w";

              "Google UK" = {
                urls = [{
                  template = "https://www.google.co.uk/search";
                  params = [{
                    name = "q";
                    value = "{searchTerms}";
                  }];
                }];
                definedAliases = [ "@g" ];
              };

              "GitHub" = {
                urls = [{
                  template = "https://github.com/search";
                  params = [{
                    name = "q";
                    value = "{searchTerms}";
                  }];
                }];
                definedAliases = [ "@gh" ];
              };

              "Nix Packages" = {
                urls = [{
                  template = "https://search.nixos.org/packages";
                  params = [
                    {
                      name = "channel";
                      value = "unstable";
                    }
                    {
                      name = "query";
                      value = "{searchTerms}";
                    }
                  ];
                }];
                definedAliases = [ "@np" ];
              };

              "NixOS Options" = {
                urls = [{
                  template = "https://search.nixos.org/options";
                  params = [
                    {
                      name = "channel";
                      value = "unstable";
                    }
                    {
                      name = "query";
                      value = "{searchTerms}";
                    }
                  ];
                }];
                definedAliases = [ "@no" ];
              };

              "NixOS Wiki" = {
                urls = [{
                  template = "https://nixos.wiki/index.php";
                  params = [{
                    name = "search";
                    value = "{searchTerms}";
                  }];
                }];
                definedAliases = [ "@nw" ];
              };

              "Nixpkgs Issues" = {
                urls = [{
                  template = "https://github.com/NixOS/nixpkgs/issues";
                  params = [{
                    name = "q";
                    value = "{searchTerms}";
                  }];
                }];
                definedAliases = [ "@ni" ];
              };

              "Nix code" = {
                urls = [{
                  template = "https://github.com/search";
                  params = [
                    {
                      name = "l";
                      value = "Nix";
                    }
                    {
                      name = "type";
                      value = "Code";
                    }
                    {
                      name = "q";
                      value = "{searchTerms}";
                    }
                  ];
                }];
                definedAliases = [ "@nc" ];
              };

              "Reddit" = {
                urls = [{
                  template = "https://old.reddit.com/search";
                  params = [
                    {
                      name = "q";
                      value = "{searchTerms}";
                    }
                    {
                      name = "include_over_18";
                      value = "on";
                    }
                  ];
                }];
                definedAliases = [ "@r" ];
              };
            };
          };
        };
      };
    };
  };
}
