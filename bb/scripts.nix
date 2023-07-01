{ pkgs, self }:
{
  ci-update = pkgs.my.write-bb {
    name = "myos-update";
    deps = with pkgs; [ nvfetcher ];
    source = (self + "/bb/update.clj");
  };
  grab-shi = pkgs.my.write-bb {
    name = "grab-shi";
    source = (self + "/bb/shi.clj");
    args = [ (self + "/resources/dicts/shi.txt") ];
  };
}
