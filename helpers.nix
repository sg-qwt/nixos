{
  profile-list =
    (map
      (mname: (./modules/profiles + "/${mname}"))
      (builtins.attrNames (builtins.readDir ./modules/profiles)));

  default-overlays =
    inputs: final: prev:
    {
      my =
        (builtins.listToAttrs
          (map
            (pkgname:
              {
                name = pkgname;
                value = prev.callPackage (./packages + "/${pkgname}") { inherit inputs; };
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

}
