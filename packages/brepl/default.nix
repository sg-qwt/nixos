{ lib
, stdenv
, makeWrapper
, babashka
, fetchFromGitHub
, ...
}:

stdenv.mkDerivation rec {
  pname = "brepl";
  version = "2.5.1";

  src = fetchFromGitHub {
    owner = "licht1stein";
    repo = "brepl";
    rev = "v${version}";
    hash = "sha256-5rv7fFRe32a1JL2BAD3mMP2b3VGtiMC+MDphhJgJkgk=";
  };

  nativeBuildInputs = [ makeWrapper ];

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp brepl $out/bin/brepl
    chmod +x $out/bin/brepl

    # Wrap to ensure babashka is on PATH
    wrapProgram $out/bin/brepl \
      --prefix PATH : ${lib.makeBinPath [ babashka ]}

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
    changelog = "https://github.com/licht1stein/brepl/releases/tag/v${version}";
    license = licenses.mpl20;
    maintainers = with maintainers; [ ];
    platforms = babashka.meta.platforms;
    mainProgram = "brepl";
  };
}
