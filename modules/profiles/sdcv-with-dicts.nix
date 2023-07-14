s@{ config, pkgs, lib, self, ... }:
lib.mkProfile s "sdcv-with-dicts" (
  let
    handict = pkgs.fetchzip {
      url = "http://download.huzheng.org/zh_CN/stardict-chibigenc-2.4.2.tar.bz2";
      sha256 = "sha256-n1QFhUUWpsYyknPmaY3mGqfMXUj6OysUsZNWvjFdu9k=";
    };
    oald = pkgs.fetchzip {
      url = "http://download.huzheng.org/dict.org/stardict-oald-2.4.2.tar.bz2";
      sha256 = "sha256-7rvIkDj6qXBJwPV4lL42IbpDCMz4t8tJ8LxHf4a2MpE=";
    };
    dictFiles = pkgs.symlinkJoin {
      name = "sdcv-dict-files";
      paths = [
        oald
        handict
      ];
    };
    mySdcv = pkgs.writeScriptBin "sdcv" ''
      exec ${pkgs.sdcv}/bin/sdcv --color --only-data-dir --data-dir ${dictFiles} "$@"
    '';
  in
  {
    environment.systemPackages = [ mySdcv ];
  }
)
