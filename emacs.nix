{ pkgs ? import <nixpkgs> {} }: 



let
  myEmacs = pkgs.emacs; 

  emacsWithPackages = (pkgs.emacsPackagesFor myEmacs).emacsWithPackages; 


in
  emacsWithPackages (epkgs: (with epkgs.melpaStablePackages; [ 

    modus-themes

  ]) ++ (with epkgs.melpaPackages; [ 
    evil
    evil-collection
    general

    orderless
    marginalia

    consult
    command-log-mode

    magit
  ]) ++ (with epkgs.elpaPackages; [ 
    use-package
    vertico

  ]) ++ [


  ])
