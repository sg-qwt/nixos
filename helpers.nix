{
  module-list =
    (map
      (mname: (./modules + "/${mname}"))
      (builtins.attrNames (builtins.readDir ./modules)));

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

  mkModule = config: lib: mname: desc: body:
    {
      options.myos."${mname}" = {
        enable = lib.mkEnableOption desc;
      };

      config = lib.mkIf config.myos."${mname}".enable body;
    };

}
