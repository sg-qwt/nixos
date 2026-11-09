{
  lib,
  stdenvNoCC,
  fetchurl,
  _7zz,
  ...
}:
stdenvNoCC.mkDerivation {
  pname = "dell-xps13-ish-firmware";
  version = "584.7785.0";

  # Dell driver 8T0WN explicitly supports the DX13260 WCL subsystem 0E53.
  src = fetchurl {
    url = "https://downloads.dell.com/FOLDER14626827M/1/Intel-Integrated-Sensor-Solution-Driver_8T0WN_WIN64_3.20.7785.0_A00.EXE";
    hash = "sha256-Pb+kuEapHjklc6AFkeqaqfXGbehC/PTufT4zproCJoQ=";
  };

  strictDeps = true;
  nativeBuildInputs = [ _7zz ];
  dontUnpack = true;
  dontBuild = true;
  dontFixup = true;

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/lib/firmware/intel/ish"
    # Use the Dell-signed extension image, not the generic Intel base image.
    # The loader prefers this Dell/WCL filename over the generic ish_wcl.bin.
    firmware="$out/lib/firmware/intel/ish/ish_wcl_39ceeaf8.bin"
    7zz x -so "$src" \
      '16299/Drivers/ISH/IshHeciExtensionTemplate/x64/FwImage/0007/ishS_SI_584.7785.0.bin' \
      > "$firmware"
    echo "d28999ed607608436bbd7aa37e5c387edcb383dbb67b65f80115ffa70c08e3e6  $firmware" \
      | sha256sum -c -

    runHook postInstall
  '';

  meta = {
    description = "Dell-signed Wildcat Lake sensor hub firmware for the XPS 13 DX13260";
    homepage = "https://www.dell.com/support/home/en-us/drivers/driversdetails?driverid=8t0wn";
    license = lib.licenses.unfree;
    sourceProvenance = [ lib.sourceTypes.binaryFirmware ];
    platforms = [ "x86_64-linux" ];
  };
}
