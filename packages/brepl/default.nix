{ lib
, stdenv
, makeWrapper
, babashka-unwrapped
, self
, fetchFromGitHub
, ...
}:

stdenv.mkDerivation rec {
  pname = "brepl";
  version = "2.7.1";

  src = fetchFromGitHub {
    owner = "licht1stein";
    repo = "brepl";
    rev = "v${version}";
    hash = "sha256-Obv2kSEsgZacY4T3HU1/FqTx4y2dRiCgk9j2tPPd3+o=";
  };

  nativeBuildInputs = [ makeWrapper ];

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    install -Dm755 brepl $out/bin/brepl
    install -Dm644 resources/skills/brepl/SKILL.md $out/share/brepl/SKILL.md

    sed -i '1s|#!/usr/bin/env.*|#!/usr/bin/env bb|' $out/bin/brepl

    # Wrap to ensure babashka is on PATH
    wrapProgram $out/bin/brepl \
      --prefix PATH : ${lib.makeBinPath [ babashka-unwrapped ]} \
      --set BABASHKA_CLASSPATH ""

    runHook postInstall
  '';

  meta = with lib; {
    description = "Bracket-fixing REPL";
    longDescription = ''
      brepl (Bracket-fixing REPL) enables AI-assisted Clojure development by solving
      the notorious parenthesis problem. It validates syntax using Babashka's built-in
      parser and intelligently fixes bracket errors with parmezan—because AI agents
      shouldn't struggle with Lisp parentheses. Provides automatic syntax validation,
      bracket auto-fix, and REPL synchronization. Also works as a fast nREPL client for
      command-line evaluations, file loading, and scripting workflows.
    '';
    homepage = "https://github.com/licht1stein/brepl";
    license = licenses.mpl20;
    platforms = babashka-unwrapped.meta.platforms;
    mainProgram = "brepl";
  };
}
