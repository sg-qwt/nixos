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
        version = "20251130.2137";
        src = pkgs.fetchFromGitHub {
          owner = "editor-code-assistant";
          repo = "eca-emacs";
          rev = "68881666b4a8d05eb279c7b4a99bfed80bc3672e";
          hash = "sha256-YlT3/tkWni18TLkxSEh+Q7lEX1T3a+g30ifDAu1gzJA=";
        };
      }))

      (epkgs.trivialBuild {
        pname = "gemini-cli";
        version = "0.2.0";
        src = pkgs.fetchFromGitHub {
          owner = "linchen2chris";
          repo = "gemini-cli.el";
          rev = "c28aef428733abae03ca1367a10beda06f65cc68";
          hash = "sha256-KDTQrQrE4JTltH/6UtgeDeiluYrKNty4KmZqrgHqnec=";
        };
        packageRequires = with epkgs; [ transient melpaPackages.popup melpaPackages.projectile ];
      })

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
    (aspellWithDicts (ds: with ds; [ en ]))
    my.bbscripts
    gemini-cli

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
