#! /usr/bin/env nix-shell
#! nix-shell -i bash -p coreutils gnused curl common-updater-scripts nuget-to-nix nix-prefetch-git jq dotnet-sdk_6
set -euo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")"

DEPS_FILE="$(realpath "./deps.nix")"

# SHA="$(nix-prefetch-git https://github.com/ryujinx/ryujinx --rev "$COMMIT" --quiet | jq -r '.sha256')"

echo "building Nuget lockfile"

STORE_SRC="$(nix-build '<nixpkgs>' -A ryujinx.src --no-out-link)"
SRC="$(mktemp -d /tmp/ryujinx-src.XXX)"
cp -rT "$STORE_SRC" "$SRC"
chmod -R +w "$SRC"
pushd "$SRC"

mkdir nuget_tmp.packages
DOTNET_CLI_TELEMETRY_OPTOUT=1 dotnet restore Ryujinx.sln --packages nuget_tmp.packages

nuget-to-nix ./nuget_tmp.packages >"$DEPS_FILE"

popd
