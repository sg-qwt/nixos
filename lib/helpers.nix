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
                value = (prev.callPackage (self + "/packages/${pkgname}") (args // { inherit self; }));
              })
            (builtins.attrNames (builtins.readDir (self + "/packages")))));

      # TODO https://github.com/NixOS/nixpkgs/pull/356133
      nix = prev.nix.override (old: {
        curl = prev.curl.overrideAttrs (oldAttrs: {
          patches = (oldAttrs.patches or [ ]) ++ [
            # https://github.com/curl/curl/issues/15496
            (prev.fetchpatch {
              url = "https://github.com/curl/curl/commit/f5c616930b5cf148b1b2632da4f5963ff48bdf88.patch";
              hash = "sha256-FlsAlBxAzCmHBSP+opJVrZG8XxWJ+VP2ro4RAl3g0pQ=";
            })
            # https://github.com/curl/curl/issues/15513
            (prev.fetchpatch {
              url = "https://github.com/curl/curl/commit/0cdde0fdfbeb8c35420f6d03fa4b77ed73497694.patch";
              hash = "sha256-WP0zahMQIx9PtLmIDyNSJICeIJvN60VzJGN2IhiEYv0=";
            })
          ];
        });
      });
    };

  packages = pkgs:
    (builtins.listToAttrs
      (map (name: { name = name; value = pkgs.my."${name}"; })
        (builtins.attrNames pkgs.my)));

  shells = args: default:
    let
      devshells =
        (builtins.foldl' (a: b: a // b) { }
          (map (sname: { "${sname}" = (import (self + "/shells/${sname}") args); })
            (builtins.attrNames (builtins.readDir (self + "/shells")))));
    in
    devshells // { default = devshells."${default}"; };
}
