{ callPackage
, fetchFromGitHub
, lib
, mkYarnPackage
, fetchYarnDeps
, nodejs
, makeWrapper
, matrix-sdk-crypto-nodejs
, ...
}:

mkYarnPackage rec {
  pname = "matrix-chatgpt-bot";
  version = "dev";
  src = fetchFromGitHub ({
    owner = "sg-qwt";
    repo = "matrix-chatgpt-bot";
    rev = "02d7976ba86fdc12377c140c44f9e21dda81cf39";
    fetchSubmodules = false;
    sha256 = "sha256-ixNWW4mkJteLJ8xGfM6278ppsvXHAY729Z7EeCkj0TI=";
  });

  packageJSON = ./package.json;
  offlineCache = fetchYarnDeps {
    yarnLock = "${src}/yarn.lock";
    sha256 = "sha256-h8xyyfhCRJW+VX7yCBFSS8Kx7tN72mnBrS1KREXlbFI=";
  };

  nativeBuildInputs = [
    makeWrapper
  ];

  buildPhase = ''
    runHook preBuild
    yarn --offline tsc
    runHook postBuild
  '';

  postInstall = ''
    out_node_path="$out/libexec/matrix-chatgpt-bot/node_modules"

    rm -r "$out_node_path/@matrix-org/matrix-sdk-crypto-nodejs"
    ln -s "${matrix-sdk-crypto-nodejs}/lib/node_modules/@matrix-org/matrix-sdk-crypto-nodejs" "$out_node_path/@matrix-org"

    makeWrapper ${nodejs}/bin/node "$out/bin/matrix-chatgpt-bot" \
      --add-flags "$out_node_path/matrix-chatgpt-bot/dist/index.js" \
      --prefix NODE_PATH : "$out_node_path"
  '';

  meta = with lib; {
    description = "Talk to ChatGPT via any Matrix client";
    homepage = "https://github.com/matrixgpt/matrix-chatgpt-bot";
    license = licenses.agpl3;
    maintainers = with maintainers; [ ];
  };
}
