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

  mylibs = {
    inherit mkProfile patchDesktop addPatches;
  };

  lib = nixpkgs.lib.extend (
    final: prev: mylibs
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
      inherit mylibs;
    };

  jovian-overlay =
    (final: prev: {
      gamescope-session = prev.gamescope-session.override {
        steam = prev.steam.override (old: {
          extraPkgs =
            pkgs: (if old ? extraPkgs then old.extraPkgs pkgs else [ ]) ++ [ pkgs.noto-fonts-cjk-sans ];
        });
      };
    });

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

  shared-data =
    (lib.importJSON (self + "/resources/shared-data/data.json")) //
    (lib.importJSON (self + "/resources/shared-data/tfo.json")) //
    {
      hosts = (builtins.attrNames self.nixosConfigurations);
    };
}
