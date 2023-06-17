{
  _gentarget = ".nixd.json";
  options = {
    enable = true;
    target = {
      args = [ ];
      installable = ".#nixosConfigurations.ge.options";
    };
  };
}
