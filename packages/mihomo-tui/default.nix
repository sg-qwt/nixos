{
  lib,
  rustPlatform,
  fetchFromGitHub,
  versionCheckHook,
  writableTmpDirAsHomeHook,
  ...
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "mihomo-tui";
  version = "0.5.2";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "potoo0";
    repo = "mihomo-tui";
    tag = "v${finalAttrs.version}";
    hash = "sha256-cvzNutvJ7ozcC4RjfPaoZ2aLlYfPxI6foVCd1x8Z0ho=";
  };

  cargoHash = "sha256-osXfAJaGx9PMZuwWqgDw1nR9MWq+FTHZzQxuN6DKRDw=";

  env = {
    # nixpkgs adds target-specific rustflags, which take precedence over
    # the build.rustflags in the upstream .cargo/config.toml.
    RUSTFLAGS = "--cfg tokio_unstable";

    # build.rs requires Git describe metadata to generate the --version information.
    VERGEN_GIT_DESCRIBE = "v${finalAttrs.version}";
    VERGEN_BUILD_DATE = "2026-07-19";
    VERGEN_DEFAULT_ON_ERROR = "1";
  };

  nativeInstallCheckInputs = [
    writableTmpDirAsHomeHook
    versionCheckHook
  ];
  # `--version` initializes the config directory and requires a writable home.
  versionCheckKeepEnvironment = [ "HOME" ];
  doInstallCheck = true;

  meta = {
    description = "A simple TUI dashboard for monitoring and managing Mihomo via its REST API";
    homepage = "https://github.com/potoo0/mihomo-tui";
    changelog = "https://github.com/potoo0/mihomo-tui/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    mainProgram = "mihomo-tui";
    platforms = lib.platforms.linux;
  };
})
