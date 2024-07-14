{ pkgs, self, lib }:
rec {
  ci-update = pkgs.my.write-bb {
    name = "myos-update";
    source = (self + "/bb/update.clj");
  };
  hosts = (lib.concatStringsSep ":" (builtins.attrNames self.nixosConfigurations));
  bento = pkgs.my.write-bb {
    name = "bento";
    deps = with pkgs; [
      brightnessctl
      libnotify
    ];
    source = (self + "/bb/bento.clj");
    pre = ''
      export MYOS_BENTO_HOSTS=${hosts}
      export MYOS_BENTO_SHI_DATA=${../resources/dicts/shi.txt}
    '';
  };
}
