{ pkgs ? import <nixpkgs> {} }: 



let
  myEmacs = pkgs.emacs; 


  emacsWithPackages = (pkgs.emacsPackagesFor myEmacs).emacsWithPackages; 


in
  emacsWithPackages (epkgs: (with epkgs.melpaStablePackages; [ 


  ]) ++ (with epkgs.melpaPackages; [ 
    evil
    evil-collection
    general

    orderless
    marginalia

    consult
  ]) ++ (with epkgs.elpaPackages; [ 
    use-package
    vertico

  ]) ++ [


  ])
