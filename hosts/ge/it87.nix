{ stdenv, lib, fetchFromGitHub, kernel }:

stdenv.mkDerivation rec {
  name = "it87-${version}-${kernel.version}";
  version = "2018-08-14";

  # The original was deleted from github, but this seems to be an active fork
  src = fetchFromGitHub {
    owner = "gamanakis";
    repo = "it87";
    rev = "it8688E";
    sha256 = "1paqk1djimwqz9vr0b1x6jr7v50wxdk71i7vwpbn772vyv2j55z0";
  };

  hardeningDisable = [ "pic" ];

  nativeBuildInputs = kernel.moduleBuildDependencies;

  preConfigure = ''
    sed -i 's|depmod|#depmod|' Makefile
  '';

  makeFlags = [
    "TARGET=${kernel.modDirVersion}"
    "KERNEL_MODULES=${kernel.dev}/lib/modules/${kernel.modDirVersion}"
    "MODDESTDIR=$(out)/lib/modules/${kernel.modDirVersion}/kernel/drivers/hwmon"
  ];

  meta = with lib; {
    description = "Patched module for IT87xx superior chip sensors support";
    homepage = "https://github.com/gamanakis/it87";
    license = licenses.gpl2;
    platforms = [ "x86_64-linux" "i686-linux" ];
    maintainers = with maintainers; [ yorickvp ];
  };
}
