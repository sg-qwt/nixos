s@{ config, pkgs, lib, helpers, ... }:
helpers.mkProfile s "sdcv-with-dicts" (
  let
    oald = pkgs.fetchzip {
      url = "http://download.huzheng.org/dict.org/stardict-oald-2.4.2.tar.bz2";
      sha256 = "sha256-7rvIkDj6qXBJwPV4lL42IbpDCMz4t8tJ8LxHf4a2MpE=";
    };
    dictFiles = pkgs.symlinkJoin {
      name = "sdcv-dict-files";
      paths = [
        oald
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
