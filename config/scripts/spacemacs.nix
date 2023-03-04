{ pkgs }:
''
  set -euo pipefail
  echo "### Spacemacs"
  if [[ -d "$HOME/.emacs.d" ]]; then
  echo "### Spacemacs exists, pull latest..."
  cd "$HOME/.emacs.d"; ${pkgs.git}/bin/git pull --rebase
  else
  echo "### Spacemacs does NOT exist, clone..."
  ${pkgs.git}/bin/git clone -b develop --depth 1 https://github.com/syl20bnr/spacemacs.git "$HOME/.emacs.d"
  fi
''
