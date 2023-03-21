{ config, lib, pkgs, rootPath, ... }:
{
  options.ports = lib.mkOption {
    type = with lib.types; attrsOf port;
    default = { };
  };

  config = {
    assertions = [
      {
        assertion =
          let
            vals = lib.attrValues config.ports;
            noCollision = l: lib.length (lib.unique l) == lib.length l;
          in
          noCollision vals;
        message = "ports collision defined in config/ports.json";
      }
    ];

    ports = lib.importJSON (rootPath + "/config/ports.json");
  };
}
