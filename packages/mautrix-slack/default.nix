{ lib, fetchFromGitHub, buildGoModule, olm, ... }:

let rev = "9b2a53fd8c9d1b57936037f775c54955c993e5be"; in
buildGoModule {
  pname = "mautrix-slack";
  version = rev;
  src = fetchFromGitHub {
    owner = "mautrix";
    repo = "slack";
    rev = rev;
    sha256 = "sha256-Ww4QDQL7A3gqBYQE1ZzwY1F8zU8dDHlmcgUa0ur3k4U=";
  };

  vendorHash = "sha256-yQe15hqzFVmNqWwMxJ3KpREa14ezaJI4jc6iBN8pRmE=";

  buildInputs = [ olm ];

  meta = with lib; {
    homepage = "https://github.com/mautrix/slack";
    description = " A Matrix-Slack puppeting bridge";
    license = licenses.agpl3Plus;
  };
}
