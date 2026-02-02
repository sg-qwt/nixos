{ lib, pkgs, emacs30-pgtk, emacsPackagesFor, self, ... }:
let
  emacsWithPackages = (emacsPackagesFor emacs30-pgtk).emacsWithPackages;

  trivialBuild = pkgs.emacsPackages.trivialBuild;

  shell-maker = trivialBuild {
    pname = "shell-maker";
    version = "unstable";
    src = self.inputs.shell-maker;
    packageRequires = [ ];
  };

  acp = trivialBuild {
    pname = "acp";
    version = "unstable";
    src = self.inputs.acp;
    packageRequires = [ ];
  };

  agent-shell = trivialBuild {
    pname = "agent-shell";
    version = "unstable";
    src = self.inputs.agent-shell;
    packageRequires = [ acp shell-maker ];
  };

  qqqemacs = emacsWithPackages (epkgs:
    [
      agent-shell
    ] ++
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
        version = "0.0.1";
        src = self.inputs.eca-emacs;
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
      epkgs.eat
    ]));

  deps = with pkgs; [
    ripgrep # consult-ripgrep
    discount # markdown-mode
    unzip # nov.el
    (hunspell.withDicts (di: [ di.en-us ]))
    my.bbscripts
    gemini-cli-bin

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
