s@{ config, pkgs, lib, helpers, self, ... }:
helpers.mkProfile s "sdcv-with-dicts" (
  let
    oald = pkgs.fetchzip {
      url = "http://download.huzheng.org/dict.org/stardict-oald-2.4.2.tar.bz2";
      sha256 = "sha256-7rvIkDj6qXBJwPV4lL42IbpDCMz4t8tJ8LxHf4a2MpE=";
    };
    kangxi = pkgs.fetchzip {
      url = "http://download.huzheng.org/zh_CN/stardict-kangxitext-2.4.2.tar.bz2";
      sha256 = "sha256-6b2OiYXgdkCHPZ+h0zrTwyEujBuwiugCWO6VV9jkGDI=";
    };
    moedict = pkgs.fetchzip {
      url = "file://${(self + "/resources/dicts/moedict.tar.gz")}";
      sha256 = "sha256-G8jr+ki59qc8guiwd7XbfUPrrLxWkq6FpanEGwVhwfU=";
    };
    dictFiles = pkgs.symlinkJoin {
      name = "sdcv-dict-files";
      paths = [
        oald
        kangxi
        moedict
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
