{ sources, self, nixpkgs }:
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
      patches = (old.patches or []) ++ patches;
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
                value = (prev.callPackage (self + "/packages/${pkgname}") (args // { nvsource = sources."${pkgname}"; }));
              })
            (builtins.attrNames (builtins.readDir (self + "/packages")))));
      sway-unwrapped = addPatches prev.sway-unwrapped [
        # https://github.com/swaywm/sway/pull/7226
        (prev.fetchpatch {
          url = "https://github.com/swaywm/sway/commit/d1c6e44886d1047b3aa6ff6aaac383eadd72f36a.patch";
          hash = "sha256-LsCoK60FKp3d8qopGtrbCFXofxHT+kOv1e1PiLSyvsA=";
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
