{ lib, pkgs, emacs30-pgtk, emacsPackagesFor, self, ... }:
let
  emacsWithPackages = (emacsPackagesFor emacs30-pgtk).emacsWithPackages;

  qqqemacs = emacsWithPackages (epkgs:
    [
      (epkgs.treesit-grammars.with-grammars
        (grammars: with grammars;
        [
          tree-sitter-yaml
          tree-sitter-typescript
        ]))
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

      gptel
      (eca.overrideAttrs (old: {
        version = "20251107.1237";
        src = pkgs.fetchFromGitHub {
          owner = "editor-code-assistant";
          repo = "eca-emacs";
          rev = "ae5c11e36c7d6c4cda206c8aa96ea2225da55434";
          hash = "sha256-9yfDD8dbTYrJggE9IYOwR1sAfeFa434Szym1Wf8ySAE=";
        };
      }))

      age
    ]) ++

    (with epkgs.elpaPackages; [
      eglot
      vertico
      corfu
      nftables-mode
      jarchive
      dired-preview
    ]));

  deps = with pkgs; [
    ripgrep # consult-ripgrep
    discount # markdown-mode
    unzip # nov.el
    (aspellWithDicts (ds: with ds; [ en ]))
    my.bbscripts

    # rage with yubikey plugin
    my.rage

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
