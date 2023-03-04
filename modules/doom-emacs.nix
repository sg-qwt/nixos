{ config, pkgs, lib, helpers, inputs, ... }:
helpers.mkModule config lib
  "doom-emacs"
  "doom-emacs"
  {
    home-manager.users."${config.myos.users.mainUser}" = {

      imports = [ inputs.nix-doom-emacs.hmModule ];

      home = {
        packages = with pkgs; [
          ripgrep
          (aspellWithDicts (ds: with ds; [ en ]))
        ];
      };

      programs.doom-emacs = rec {
        enable = true;
        doomPrivateDir = ../config/doom-emacs;
        emacsPackage = pkgs.emacsPgtkNativeComp;
      };

      home.sessionVariables.EDITOR = "emacsclient";
    };
  }
