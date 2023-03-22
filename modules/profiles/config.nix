{ config, lib, pkgs, rootPath, ... }:
{
  options.myos.data = lib.mkOption {
    type = with lib.types; attrsOf anything;
    default = { };
  };

  config =
      {
      assertions = [
        {
          assertion =
            let
              vals = lib.attrValues config.myos.data.ports;
              noCollision = l: lib.length (lib.unique l) == lib.length l;
            in
              noCollision vals;
          message = "ports collision defined in config/data.json";
        }
      ];
      myos.data = lib.importJSON (rootPath + "/config/data.json");
      } ;
}
