{ config, workingDir }:
let
  inherit (config.myos.data) fqdn;
in
{
  version = 2;

  global = {
    server_name = "${fqdn.edg}";

    # nix-shell -p dendrite --run 'generate-keys --private-key /tmp/key'
    private_key = "$CREDENTIALS_DIRECTORY/dendrite-sign-key";

    cache = {
      max_age = "1h";
      max_size_estimated = "1gb";
    };

    database = {
      max_open_conns = 95;
      max_idle_conns = 5;
      conn_max_lifetime = -1;
      connection_string =
        "postgres:///dendrite?host=/run/postgresql";
    };

    disable_federation = false;

    dns_cache = {
      enabled = false;
    };

    jetstream = {
      in_memory = false;
      storage_path = "${workingDir}";
      topic_prefix = "Dendrite";
    };

    key_validity_period = "168h0m0s";

    metrics = {
      enabled = false;
    };

    presence = {
      enable_inbound = false;
      enable_outbound = false;
    };

    report_stats = {
      enabled = false;
    };

    server_notices = {
      enabled = false;
    };

    trusted_third_party_id_servers = [ "matrix.org" "vector.im" ];
  };

  client_api = {
    registration_disabled = true;
    guests_disabled = true;
    registration_shared_secret = "$REGISTRATION_SHARED_SECRET";
  };

  federation_api = {
    key_perspectives = [{
      server_name = "matrix.org";
      keys = [
        {
          key_id = "ed25519:auto";
          public_key = "Noi6WqcDj0QmPxCNQqgezwTlBKrfqehY1u2FyWP9uYw";
        }
        {
          key_id = "ed25519:a_RXGa";
          public_key = "l8Hft5qXKn1vfHrg3p4+W8gELQVo8N13JkluMfmn2sQ";
        }
      ];
    }];
    disable_http_keepalives = false;
    disable_tls_validation = false;
    prefer_direct_fetch = false;
    send_max_retries = 16;
  };

  logging = [
    {
      level = "warn";
      type = "std";
    }
  ];

  media_api = {
    base_path = "${workingDir}/media_store";
    dynamic_thumbnails = false;
    max_file_size_bytes = 10485760;
    max_thumbnail_generators = 10;
    thumbnail_sizes = [
      {
        height = 32;
        method = "crop";
        width = 32;
      }
      {
        height = 96;
        method = "crop";
        width = 96;
      }
      {
        height = 480;
        method = "scale";
        width = 640;
      }
    ];
  };

  sync_api = {
    search = {
      enabled = true;
      index_path = "${workingDir}/searchindex";
      language = "cjk";
    };
  };

  tracing = {
    enabled = false;
  };

  user_api = {
    bcrypt_cost = 10;
  };
}
