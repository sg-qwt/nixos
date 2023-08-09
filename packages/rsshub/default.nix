{ lib
, stdenv
, stdenvNoCC
, fetchFromGitHub
, nodePackages
, jq
, moreutils
, esbuild
, nodejs
, buildGoModule
, makeWrapper
, ...
}:

stdenv.mkDerivation rec {
  pname = "rsshub";
  version = "f440e22b54eca048943ec99ae235227b7092667e";

  src = fetchFromGitHub {
    owner = "DIYgod";
    repo = "RSSHub";
    rev = version;
    hash = "sha256-z+phlTuEEO9toxpk4BWxlsA/02z/zh8yKSpiBD4+3k8=";
  };

  pnpm-deps = stdenvNoCC.mkDerivation {
    pname = "${pname}-pnpm-deps";
    inherit src version;

    nativeBuildInputs = [
      jq
      moreutils
      nodePackages.pnpm
    ];

    installPhase = ''
      export HOME=$(mktemp -d)
      pnpm config set store-dir $out
      # use --ignore-script and --no-optional to avoid downloading binaries
      # use --frozen-lockfile to avoid checking git deps
      pnpm install --frozen-lockfile --no-optional --ignore-script --prod

      # Remove timestamp and sort the json files
      rm -rf $out/v3/tmp
      for f in $(find $out -name "*.json"); do
        sed -i -E -e 's/"checkedAt":[0-9]+,//g' $f
        jq --sort-keys . $f | sponge $f
      done
    '';

    dontFixup = true;
    outputHashMode = "recursive";
    outputHash = "sha256-wxCJlV5OV75jruo2cPpmz9PjxPBqxwecIGtC04t6lPg=";
  };

  nativeBuildInputs = [
    nodePackages.pnpm
    nodePackages.npm
    nodejs
    makeWrapper
  ];

  ESBUILD_BINARY_PATH = "${lib.getExe (esbuild.override {
    buildGoModule = args: buildGoModule (args // rec {
      version = "0.14.7";
      src = fetchFromGitHub {
        owner = "evanw";
        repo = "esbuild";
        rev = "v${version}";
        hash = "sha256-aDzUMP6VmtQ2VMY4axOVTBdAi+yTW+RQIrjXdsbbqV8=";
      };
      vendorHash = "sha256-QPkBR+FscUc3jOvH7olcGUhM6OW4vxawmNJuRQxPuGs=";
    });
  })}";

  preBuild = ''
    export HOME=$(mktemp -d)
    export DEPS=$(mktemp -d)

    cp -R ${pnpm-deps} $DEPS/deps

    chmod -R +w $DEPS/deps
    pnpm config set store-dir $DEPS/deps
    pnpm install --offline --frozen-lockfile --no-optional --ignore-script --prod

    chmod -R +w node_modules

    npm_config_nodedir=${nodejs} PUPPETEER_SKIP_DOWNLOAD=true pnpm rebuild
  '';

  installPhase = ''
    mkdir -p $out/rsshub
    cp -r . $out/rsshub
    
    makeWrapper ${nodejs}/bin/node $out/bin/rsshub \
              --add-flags $out/rsshub/lib/index.js
  '';


  meta = with lib; {
    description = "Everything is RSSible";
    homepage = "https://docs.rsshub.app";
    platforms = platforms.linux;
    license = licenses.mit;
  };
}
