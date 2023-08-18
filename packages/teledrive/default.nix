{ fetchFromGitHub
, lib
, fetchYarnDeps
, nodejs
, yarn2nix-moretea
, makeWrapper
, prisma-engines
, applyPatches
, symlinkJoin
, ...
}:
let
  yarnLock = ./yarn.lock;
  workspace =
    (yarn2nix-moretea.mkYarnWorkspace {
      pname = "teledrive";
      version = "ade6b9488953684c478167bbfed3e9868798a814";
      src = applyPatches {
        src = fetchFromGitHub ({
          owner = "mgilangjanuar";
          repo = "teledrive";
          rev = "ade6b9488953684c478167bbfed3e9868798a814";
          fetchSubmodules = false;
          sha256 = "sha256-akkvHesKkBQNBZD+SZ1oJd9aMQHBCL7TI7cMfxe+2go=";
        });
        postPatch = ''
          substituteInPlace api/package.json --replace '^4.4.2' '^4.1.5'

          substituteInPlace api/src/index.ts --replace "path.join(__dirname, '..', '..', 'web', 'build')" 'process.env.WEB_DIR'

          substituteInPlace api/src/index.ts --replace "path.join(__dirname, '..', '..','web', 'build', 'index.html')" "path.join(process.env.WEB_DIR, 'index.html')"

          substituteInPlace api/src/api/v1/Files.ts --replace '`''${__dirname}/../../../../.cached`' "process.env.CACHE_DIR"
        '';

      };

      inherit yarnLock;

      offlineCache = fetchYarnDeps {
        inherit yarnLock;
        sha256 = "sha256-VfujjED1WwCkjabnD18aAS89usQwV2G6fP3woTamAXE=";
      };

      nativeBuildInputs = [
        makeWrapper
      ];

      packageOverrides = {
        web = {
          buildPhase = ''
            runHook preBuild

            export HOME=$(mktemp -d)
            export WRITABLE_NODE_MODULES="$(pwd)/tmp"

            mkdir -p "$WRITABLE_NODE_MODULES"
            cd deps/web
            node_modules="$(readlink node_modules)"
            rm node_modules
            mkdir -p "$WRITABLE_NODE_MODULES"/.cache
            cp -r $node_modules/* "$WRITABLE_NODE_MODULES"

            mkdir -p "$WRITABLE_NODE_MODULES"/.bin
            for x in "$node_modules"/.bin/*; do
             ln -sfv "$node_modules"/.bin/"$(readlink "$x")" "$WRITABLE_NODE_MODULES"/.bin/"$(basename "$x")"
            done

            ln -sfv "$WRITABLE_NODE_MODULES" node_modules
            cd ../..

            yarn --offline build 

            runHook postBuild
          '';
        };
        api = {

          buildPhase = ''
            runHook preBuild
            export PRISMA_SCHEMA_ENGINE_BINARY=${prisma-engines}/bin/schema-engine
            export PRISMA_QUERY_ENGINE_BINARY=${prisma-engines}/bin/query-engine
            export PRISMA_QUERY_ENGINE_LIBRARY=${prisma-engines}/lib/libquery_engine.node
            export HOME=$(mktemp -d)
            yarn --offline build 
            runHook postBuild
          '';

          postInstall = ''
            makeWrapper ${nodejs}/bin/node $out/bin/teledrive \
              --add-flags $out/libexec/api/deps/api/dist/index.js \
              --set PRISMA_SCHEMA_ENGINE_BINARY "${prisma-engines}/bin/schema-engine" \
              --set PRISMA_QUERY_ENGINE_BINARY "${prisma-engines}/bin/query-engine" \
              --set PRISMA_QUERY_ENGINE_LIBRARY "${prisma-engines}/lib/libquery_engine.node"

            makeWrapper ${nodejs}/bin/node $out/bin/teledrive-migrate-deploy \
              --add-flags $out/libexec/api/node_modules/prisma/build/index.js \
              --add-flags migrate \
              --add-flags deploy \
              --append-flags "--schema $out/libexec/api/deps/api/prisma/schema.prisma" \
              --set PRISMA_SCHEMA_ENGINE_BINARY "${prisma-engines}/bin/schema-engine" \
              --set PRISMA_QUERY_ENGINE_BINARY "${prisma-engines}/bin/query-engine" \
              --set PRISMA_QUERY_ENGINE_LIBRARY "${prisma-engines}/lib/libquery_engine.node" \
          '';
        };
      };

      meta = with lib; {
        description = "teledrive";
        homepage = "https://github.com/mgilangjanuar/teledrive";
        license = licenses.gpl3;
      };
    });
in
symlinkJoin {
  name = "teledrive";
  paths = [ workspace.api ];
  buildInputs = [ makeWrapper ];
  postBuild = ''
    wrapProgram $out/bin/teledrive \
      --set WEB_DIR "${workspace.web}/libexec/web/deps/web/build"
  '';
}
