{ self, nixpkgs }:
rec {
  patchDesktop = pkgs: pkg: appName: from: to: lib.hiPrio
    (pkgs.runCommand "$patched-desktop-entry-for-${appName}" { }
      ''
        ${pkgs.coreutils}/bin/mkdir -p $out/share/applications
        ${pkgs.gnused}/bin/sed 's#${from}#${to}#g' < ${pkg}/share/applications/${appName}.desktop > $out/share/applications/${appName}.desktop
      '');

  profile-list =
    (map
      (mname: (self + "/modules/profiles/${mname}"))
      (builtins.attrNames (builtins.readDir (self + "/modules/profiles"))));

  mkProfile = s: pname: body:
    {
      options.myos."${pname}" = {
        enable = s.lib.mkEnableOption pname;
      };

      config = s.lib.mkIf s.config.myos."${pname}".enable body;
    };

  addPatches = pkg: patches:
    pkg.overrideAttrs (old: {
      patches = (old.patches or [ ]) ++ patches;
    });

  lib = nixpkgs.lib.extend (
    final: prev: {
      inherit mkProfile patchDesktop addPatches;
    }
  );

  default-overlays =
    args: final: prev:
    {
      my =
        (builtins.listToAttrs
          (map
            (pkgname:
              {
                name = pkgname;
                value = (prev.callPackage (self + "/packages/${pkgname}") args);
              })
            (builtins.attrNames (builtins.readDir (self + "/packages")))));
      sway-unwrapped = addPatches prev.sway-unwrapped [
        # text_input: Implement input-method popups
        # https://github.com/swaywm/sway/pull/7226
        (prev.fetchpatch rec {
          name = "0001-text_input-Implement-input-method-popups.patch";
          url = "https://aur.archlinux.org/cgit/aur.git/plain/${name}?h=sway-im&id=b8434b3ad9e8c6946dbf7b14b0f7ef5679452b94";
          hash = "sha256-A+rBaWMWs616WllVoo21AJaf9lxg/oCG0b9tHLfuJII=";
        })
        (prev.fetchpatch rec {
          name = "0002-chore-fractal-scale-handle.patch";
          url = "https://aur.archlinux.org/cgit/aur.git/plain/${name}?h=sway-im&id=b8434b3ad9e8c6946dbf7b14b0f7ef5679452b94";
          hash = "sha256-YOFm0A4uuRSuiwnvF9xbp8Wl7oGicFGnq61vLegqJ0E=";
        })
        (prev.fetchpatch rec {
          name = "0003-chore-left_pt-on-method-popup.patch";
          url = "https://aur.archlinux.org/cgit/aur.git/plain/${name}?h=sway-im&id=b8434b3ad9e8c6946dbf7b14b0f7ef5679452b94";
          hash = "sha256-PzhQBRpyB1WhErn05UBtBfaDW5bxnQLRKWu8jy7dEiM=";
        })
      ];
    };

  packages = pkgs:
    (builtins.listToAttrs
      (map (name: { name = name; value = pkgs.my."${name}"; })
        (builtins.attrNames pkgs.my))) //
    (import (self + "/bb/scripts.nix") { inherit pkgs self; });

  shells = args: default:
    let
      devshells =
        (builtins.foldl' (a: b: a // b) { }
          (map (sname: { "${sname}" = (import (self + "/shells/${sname}") args); })
            (builtins.attrNames (builtins.readDir (self + "/shells")))));
    in
    devshells // { default = devshells."${default}"; };
}
