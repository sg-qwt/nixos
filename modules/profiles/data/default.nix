{ config, lib, self, ... }:
{
  options.myos.data = lib.mkOption {
    type = with lib.types; attrsOf anything;
    default = { };
  };

  config =
    let
      data-json = lib.importJSON ./data.json;
      tfo-json = lib.importJSON ./tfo.json;
      hosts = (builtins.attrNames self.nixosConfigurations);
      openssh-keys = [
        "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIK9vRLHnJ+stWj636G27/Xp06+Q1jsV4vks/bDNOD9dKAAAABHNzaDo= main"
        "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIEAj84opeeWFMY1yxMzG3WvUVRxVhfxeauPEX6zuMWiyAAAABHNzaDo= backup"
      ];
      data = data-json // tfo-json // { inherit hosts openssh-keys; };
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
