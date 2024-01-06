{ pkgs, self }:
{
  ci-update = pkgs.my.write-bb {
    name = "myos-update";
    source = (self + "/bb/update.clj");
  };

  bento = pkgs.my.write-bb {
    name = "bento";
    deps = with pkgs; [
      brightnessctl
      libnotify
    ];
    source = (self + "/bb/bento.clj");
    pre = ''
      export SHI_DATA=${../resources/dicts/shi.txt}
    '';
  };
}
