{
  profile-list =
    (map
      (mname: (./modules/profiles + "/${mname}"))
      (builtins.attrNames (builtins.readDir ./modules/profiles)));

  default-overlays =
    args: final: prev:
    {
      my =
        (builtins.listToAttrs
          (map
            (pkgname:
              {
                name = pkgname;
                value = (prev.callPackage (./packages + "/${pkgname}") args);
              })
            (builtins.attrNames (builtins.readDir ./packages))));
    };

  mkProfile = s: pname: body:
    {
      options.myos."${pname}" = {
        enable = s.lib.mkEnableOption pname;
      };

      config = s.lib.mkIf s.config.myos."${pname}".enable body;
    };

  shells = args:
    (builtins.foldl' (a: b: a // b) { }
      (map (sname: { "${sname}" = (import (./shells + "/${sname}") args); })
        (builtins.attrNames (builtins.readDir ./shells))));
}
