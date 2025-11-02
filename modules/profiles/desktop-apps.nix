s@{ pkgs, lib, ... }:
let
  search-url = "https://www.google.co.uk";
  search-code = shortcut: language: {
    name = "${language} Code";
    shortcut = "${shortcut}";
    url = "https://github.com/search?q={searchTerms}+NOT+is%3Afork+language%3A\"${language}\"&type=code";
  };
in
lib.mkProfile s "desktop-apps"
{
  # file manager
  services.gvfs.enable = true;
  programs.thunar.enable = true;

  programs.chromium = {
    enable = true;
    homepageLocation = search-url;
    defaultSearchProviderEnabled = true;
    defaultSearchProviderSearchURL = "${search-url}/search?q={searchTerms}";
    defaultSearchProviderSuggestURL = "${search-url}/complete/search?output=chrome&q={searchTerms}";
    extensions = [
      "dbepggeogbaibhgnhhndojpepiihcmeb" # vimium
      "knheggckgoiihginacbkhaalnibhilkk" # notion-web-clipper
      "bhhhlbepdkbapadjdnnojkbgioiodbic" # solflare-wallet
      "kdbmhfkmnlmbkgbabkdealhhbfhlmmon" # steamdb
      "ngonfifpkpeefnhelnfdkficaiihklid" # protondb-for-steam
      "gebbhagfogifgggkldgodflihgfeippi" # return-youtube-dislike
      "lkbebcjgcmobigpeffafkodonchffocl;https://gitflic.ru/project/magnolia1234/bpc_updates/blob/raw?file=updates.xml" # bypass-paywall

    ];
    extraOpts = {
      BraveRewardsDisabled = true;
      BraveWalletDisabled = true;
      BraveVPNDisabled = true;
      BraveAIChatEnabled = false;
      TorDisabled = true;

      PasswordManagerEnabled = false;
      PasswordSharingEnabled = false;
      PasswordLeakDetectionEnabled = false;

      MetricsReportingEnabled = false;
      SafeBrowsingExtendedReportingEnabled = false;
      SafeBrowsingSurveysEnabled = false;
      SafeBrowsingDeepScanningEnabled = false;

      NewTabPageLocation = search-url;

      SiteSearchSettings = [
        (search-code "nc" "Nix")
        (search-code "ec" "Emacs+Lisp")
        {
          name = "Clojure Code";
          shortcut = "cc";
          url = "https://github.com/search?q={searchTerms}+NOT+is%3Afork+language%3AClojure+OR+language%3Aedn&type=code";
        }
        {
          name = "NixOS Packages";
          shortcut = "np";
          url = "https://search.nixos.org/packages?channel=unstable&query={searchTerms}";
        }
        {
          name = "NixOS Options";
          shortcut = "no";
          url = "https://search.nixos.org/options?channel=unstable&query={searchTerms}";
        }
        {
          name = "NixOS Wiki";
          shortcut = "nw";
          url = "https://wiki.nixos.org/w/index.php?search={searchTerms}";
        }
        {
          name = "Home Manager Options";
          shortcut = "ho";
          url = "https://home-manager-options.extranix.com/?query={searchTerms}&release=master";
        }
        {
          name = "Nixpkgs GitHub";
          shortcut = "ni";
          url = "https://github.com/search?q=repo%3ANixOS%2Fnixpkgs%20{searchTerms}";
        }
        {
          name = "ProtonDB";
          shortcut = "pd";
          url = "https://protondb.com/search?q={searchTerms}";
        }
        {
          name = "Steam Store";
          shortcut = "steam";
          url = "https://store.steampowered.com/search/?term={searchTerms}";
        }
        {
          name = "Wikipedia";
          shortcut = "wiki";
          url = "https://en.wikipedia.org/w/index.php?search={searchTerms}";
        }
        {
          name = "Reddit";
          shortcut = "red";
          url = "https://old.reddit.com/search?q={searchTerms}&include_over_18=on";
        }
        {
          name = "Arch Wiki";
          shortcut = "arch";
          url = "https://wiki.archlinux.org/index.php?search={searchTerms}";
        }
      ];
    };
  };

  myhome = { config, ... }:
    let
      brave-pkg = (pkgs.brave.override {
        commandLineArgs = [
          "--enable-wayland-ime"
          "--wayland-text-input-version=3"
          "--enable-features=WaylandLinuxDrmSyncobj"
          "--password-store=basic"
        ];
      });
      browser = lib.getExe brave-pkg;
      make-webapp = name: app: (pkgs.makeDesktopItem {
        inherit name;
        desktopName =
          (lib.strings.toUpper (builtins.substring 0 1 name)) +
          (builtins.substring 1 (-1) name);
        exec = "${browser} --new-window --app=\"${app}\"";
      });
    in
    {
      programs.mpv = {
        enable = true;
        config = {
          profile = "gpu-hq";
          hwdec = "auto";
          ytdl-raw-options = "cookies-from-browser=brave";
          input-ipc-server = "/tmp/mpvsocket";
        };
      };

      home.packages = with pkgs; [
        brave-pkg
        firefox

        # media
        spotify
        dmlive
        libation

        # chat
        (make-webapp "element" "https://app.element.io")
        (make-webapp "slack" "https://app.slack.com/client")
        (make-webapp "discord" "https://discord.com/app")
        (make-webapp "telegram" "https://web.telegram.org")
      ];
    };
}
