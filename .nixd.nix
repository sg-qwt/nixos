# nix eval --json --file .nixd.nix > .nixd.json
{
  options = {
    enable = true;
    target = {
      args = [ ];
      installable = ".#nixosConfigurations.ge.options";
    };
  };
}
