{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  pkg-config,
  openssl,
  zlib,
  curl,
  uthash,
  mosquitto,
  cjson,
  client ? "orca_slicer",
  pluginVersion ? "02.03.00.99",
  ...
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "open-bamboo-networking";
  version = "2.0.0";

  strictDeps = true;
  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "ClusterM";
    repo = "open-bamboo-networking";
    tag = "v${finalAttrs.version}";
    hash = "sha256-NAnPEGgctcfE6Hq+E1xagTAMswFnjqupPlkFdrBqzGo=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    openssl
    zlib
    curl
    uthash
  ];

  cmakeFlags = [
    (lib.cmakeFeature "OBN_VERSION" pluginVersion)
    (lib.cmakeFeature "OBN_CLIENT_TYPE" client)
    (lib.cmakeBool "OBN_RELEASE" true)
    (lib.cmakeBool "OBN_PATCH_CLIENT_CONF" false)
    (lib.cmakeBool "OBN_BUILD_TESTS" false)
    # Prefer a staged Nix install, not ~/.config/BambuStudio
    (lib.cmakeFeature "CMAKE_INSTALL_PREFIX" "${placeholder "out"}")
    (lib.cmakeFeature "FETCHCONTENT_SOURCE_DIR_CJSON" "${cjson.src}")
  ];

  preConfigure = ''
    cp -r ${mosquitto.src} $TMPDIR/source/mosquitto-src
    chmod -R u+w $TMPDIR/source/mosquitto-src

    cmakeFlagsArray+=(
      "-DFETCHCONTENT_SOURCE_DIR_ECLIPSE_MOSQUITTO=$TMPDIR/source/mosquitto-src"
    )
  '';

  meta = {
    description = "Open-source Bambu/Orca network plugin replacement";
    platforms = lib.platforms.linux;
  };
})
