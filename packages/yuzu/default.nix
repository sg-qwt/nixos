{ branch ? "mainline"
, libsForQt5
, fetchFromGitHub
, fetchurl
, ...
}:

let
  # Fetched from https://api.yuzu-emu.org/gamedb, last updated 2022-07-14
  # Please make sure to update this when updating yuzu!
  compat-list = fetchurl {
    name = "yuzu-compat-list";
    url = "https://web.archive.org/web/20220714160745/https://api.yuzu-emu.org/gamedb";
    sha256 = "sha256-anOmO7NscHDsQxT03+YbJEyBkXjhcSVGgKpDwt//GHw=";
  };
in
{
  mainline = libsForQt5.callPackage ./generic.nix rec {
    pname = "yuzu-mainline";
    version = "1107";

    src = fetchFromGitHub {
      owner = "yuzu-emu";
      repo = "yuzu-mainline";
      rev = "mainline-0-${version}";
      sha256 = "0asxf0b17r1rg9d03gijmil3bml9872srym3z89nh8w5sv2sixz3";
      fetchSubmodules = true;
    };

    inherit branch compat-list;
  };

  early-access = libsForQt5.callPackage ./generic.nix rec {
    pname = "yuzu-ea";
    version = "2858";

    src = fetchFromGitHub {
      owner = "pineappleEA";
      repo = "pineapple-src";
      rev = "EA-${version}";
      sha256 = "0v5m8796j6hzv689f7gi5yl4d2vqyfd16i485v77rmjpa6pd5x99";
      fetchSubmodules = true;
    };

    inherit branch compat-list;
  };
}.${branch}
