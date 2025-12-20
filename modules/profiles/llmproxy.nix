{ config, lib, inputs, self, pkgs, ... }:
with lib;
let
  inherit (self.shared-data) ports fqdn;
  cfg = config.myos.llmproxy;
  host = "127.0.0.1";
  serviceName = "litellm";
  host-addr = "llmproxy.${fqdn.edg}";
  gemini-models =
    [
      "gemini-3-pro-preview"
      "gemini-3-flash-preview"
      "gemini-2.5-pro"
      "gemini-2.5-flash"
    ] |>
    (map (model:
      {
        model_name = model;
        litellm_params = {
          model = "openai/${model}";
          litellm_credential_name = "gmn_cred";
        };
      }));
  settings = {
    general_settings = {
      store_model_in_db = false;
      disable_spend_logs = true;
      disable_error_logs = true;
    };
    litellm_settings = {
      num_retries = 3;
      cache = false;
      drop_params = true;
      fallbacks = [
        { "gpt-5-mini" = ["gpt-5-mini-alt"]; }
      ];
    };
    credential_list = [
      {
        credential_name = "az_cred";
        credential_values = {
          api_base = "https://${self.shared-data.az-anu-domain}.openai.azure.com";
          api_key = "os.environ/AZURE_ANU_API_KEY";
        };
        credential_info = {
          description = "base az cred";
        };
      }
      {
        credential_name = "gmn_cred";
        credential_values = {
          api_base = "https://gemini.${fqdn.edg}/v1";
          api_key = "os.environ/GEMINI_PROXY_KEY";
        };
        credential_info = {
          description = "base gemini cred";
        };
      }
    ];
    model_list = [
      {
        model_name = "gpt-5-mini";
        litellm_params = {
          model = "azure/gpt-5-mini";
          litellm_credential_name = "az_cred";
        };
      }
      {
        model_name = "gpt-5-mini-alt";
        litellm_params = {
          model = "azure/gpt-5-mini-alt";
          litellm_credential_name = "az_cred";
        };
      }
      {
        model_name = "gpt-5.2-chat";
        litellm_params = {
          model = "azure/gpt-5.2-chat";
          litellm_credential_name = "az_cred";
        };
      }
      {
        model_name = "claude-opus-4-5";
        litellm_params = {
          model = "anthropic/claude-opus-4-5";
          api_base = "https://${self.shared-data.az-anu-domain}.openai.azure.com/anthropic";
          api_key = "os.environ/AZURE_ANU_API_KEY";
        };
      }
    ] ++ gemini-models;
  };
in
{
  options.myos.llmproxy = {
    enable = mkEnableOption "litellm service";
  };

  config = mkIf cfg.enable {

    vaultix.secrets.litellm-env = { };

    systemd.services.litellm.serviceConfig.SupplementaryGroups = [ config.users.groups.root.name ];

    services.litellm = {
      inherit host settings;
      enable = true;
      port = ports.litellm;
      openFirewall = true;
      environment = {
        NO_DOCS = "True";
        DISABLE_ADMIN_UI = "True";
        DISABLE_ADMIN_ENDPOINTS = "True";
      };
      environmentFile = config.vaultix.secrets.litellm-env.path;
    };

    services.nginx.virtualHosts."${host-addr}" = {
      forceSSL = true;
      useACMEHost = "edg";
      locations."/" = {
        proxyPass = "http://${host}:${toString ports.litellm}";
      };
    };
  };
}

