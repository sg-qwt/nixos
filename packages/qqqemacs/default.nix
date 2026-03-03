{ lib, pkgs, emacs30-pgtk, emacsPackagesFor, self, ... }:
let
  emacsWithPackages = (emacsPackagesFor emacs30-pgtk).emacsWithPackages;

  trivialBuild = pkgs.emacsPackages.trivialBuild;

  pi-coding-agent = trivialBuild {
    pname = "pi-coding-agent";
    version = "0.0.1";
    src = self.inputs.pi-coding-agent;
    packageRequires = [ pkgs.emacsPackages.transient ];
  };

  ts-grammers = epkgs: (epkgs.treesit-grammars.with-grammars
    (grammars: with grammars;
      [
        tree-sitter-yaml
        tree-sitter-typescript
        tree-sitter-json
        tree-sitter-python
        tree-sitter-javascript
        tree-sitter-tsx
        tree-sitter-bash
        tree-sitter-c
        tree-sitter-cpp
        tree-sitter-rust
        tree-sitter-go
        tree-sitter-ruby
        tree-sitter-css
        tree-sitter-html
        tree-sitter-java
        tree-sitter-lua
        tree-sitter-toml
        tree-sitter-cmake
        tree-sitter-dockerfile
        tree-sitter-c-sharp
        tree-sitter-elixir
        tree-sitter-haskell
        tree-sitter-heex
        tree-sitter-kotlin
        tree-sitter-gomod
        tree-sitter-php
        tree-sitter-scala

        tree-sitter-markdown
        tree-sitter-markdown-inline

        (pkgs.tree-sitter.buildGrammar {
          language = "clojure";
          version = "unstable-20250526";
          src = pkgs.fetchFromGitHub {
            owner = "sogaiu";
            repo = "tree-sitter-clojure";
            rev = "69070d2e4563f8f58c7f57b0c8e093a08d7a5814";
            sha256 = "sha256-+Miraf8kI8rZg7SYdfNM+mb78k9xNDUKYg3VTFzUHMo=";
          };
        })
      ]));

  qqqemacs = emacsWithPackages (epkgs:
    [
      pi-coding-agent
      (ts-grammers epkgs)
    ] ++

    (with epkgs.melpaStablePackages; [
      clojure-mode
      clojure-mode-extra-font-locking
      cider
      cider-eval-sexp-fu

      markdown-mode
    ]) ++

    (with epkgs.melpaPackages; [
      avy
      evil
      evil-surround
      evil-collection
      evil-org
      general

      orderless
      marginalia
      consult
      cape
      company # for company backends

      command-log-mode

      magit

      nix-mode
      hcl-mode
      clojure-ts-mode # only used for pi

      embark
      embark-consult
      wgrep

      smartparens
      evil-cleverparens

      pdf-tools
      nov

      yasnippet
      yasnippet-capf

      ibuffer-vc

      vterm
      multi-vterm

      hl-todo

      rust-mode

      age
    ]) ++

    (with epkgs.elpaPackages; [
      eglot
      vertico
      corfu
      nftables-mode
      jarchive
      dired-preview
      epkgs.eat
    ]));

  deps = with pkgs; [
    ripgrep # consult-ripgrep
    discount # markdown-mode
    unzip # nov.el
    (hunspell.withDicts (di: [ di.en-us ]))

    my.bbscripts

    my.sdcv

    # rage with yubikey plugin
    my.rage

    llm-agents.pi

    # lsp
    nil
    clojure-lsp
  ];
in
pkgs.symlinkJoin {
  name = "qqqemacs";
  paths = [ qqqemacs ];
  nativeBuildInputs = [ pkgs.makeWrapper ];
  postBuild = ''
    wrapProgram $out/bin/emacs \
      --set QQQ_SNIPPETS ${./snippets} \
      --set QQQ_AGE_RECIPIENTS ${self + "/resources/keys/recipients.txt"} \
      --set QQQ_AGE_IDENTITY ${self + "/resources/keys/age-yubikey-identity-main.txt"} \
      --prefix PATH : ${lib.makeBinPath deps} \
      --add-flags --init-directory=${./init}
  '';
}
