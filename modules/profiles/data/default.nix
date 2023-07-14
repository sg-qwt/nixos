{ config, lib, ... }:
{
  options.myos.data = lib.mkOption {
    type = with lib.types; attrsOf anything;
    default = { };
  };

  config =
    let
      data-json =  builtins.fromJSON ./data.json;
      hosts = (builtins.attrNames self.nixosConfigurations);
      data = data-json // { hosts = hosts; };
    in
    {
      assertions = [
        {
          assertion =
            let
              vals = lib.attrValues config.myos.data.ports;
              noCollision = l: lib.length (lib.unique l) == lib.length l;
            in
            noCollision vals;
          message = "ports collision defined in data.json";
        }
      ];
      myos.data = data;
    };
}
