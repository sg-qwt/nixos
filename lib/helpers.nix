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

      # TODO https://github.com/NixOS/nixpkgs/pull/356133
      nixVersions = prev.nixVersions.extend (
        _: nPrev: {
          nix_2_24_sysroot =
            (nPrev.nix_2_24.overrideAttrs (old: {
              patches = (old.patches or [ ]) ++ [
                ./nix-local-overlay-store-regex.patch
              ];
            })).override
              {
                # TODO(jared): delete when https://github.com/NixOS/nixpkgs/pull/356133 is on nixos-unstable
                curl = final.curl.overrideAttrs (old: {
                  patches = (old.patches or [ ]) ++ [
                    (final.fetchpatch {
                      url = "https://raw.githubusercontent.com/NixOS/nixpkgs/d508b59825a6c86aa0ba5eedc72042bfbe97e791/pkgs/by-name/cu/curlMinimal/fix-netrc-regression.patch";
                      hash = "sha256-/0MnDxsurz9BGhuf+57XXdWH0WKfexeRuKRD8deRl4Q=";
                    })
                  ];
                });
              };
        }
      );
    };

  packages = pkgs:
    (builtins.listToAttrs
      (map (name: { name = name; value = pkgs.my."${name}"; })
        (builtins.attrNames pkgs.my))) //
    (import (self + "/bb/scripts.nix") { inherit lib pkgs self; });

  shells = args: default:
    let
      devshells =
        (builtins.foldl' (a: b: a // b) { }
          (map (sname: { "${sname}" = (import (self + "/shells/${sname}") args); })
            (builtins.attrNames (builtins.readDir (self + "/shells")))));
    in
    devshells // { default = devshells."${default}"; };
}
