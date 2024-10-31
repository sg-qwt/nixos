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
      sway-unwrapped =
        (prev.sway-unwrapped.override { wlroots = final.wlroots_0_18; }).overrideAttrs
          (
            finalAttrs: prevAttrs: {
              version = "1.10";
              src = prevAttrs.src.override {
                hash = "sha256-PzeU/niUdqI6sf2TCG19G2vNgAZJE5JCyoTwtO9uFTk=";
              };

              mesonFlags =
                let
                  inherit (final.lib.strings) mesonEnable mesonOption;
                  sd-bus-provider = if finalAttrs.systemdSupport then "libsystemd" else "basu";
                in
                  [
                    (mesonOption "sd-bus-provider" sd-bus-provider)
                    (mesonEnable "tray" finalAttrs.trayEnabled)
                  ];
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
