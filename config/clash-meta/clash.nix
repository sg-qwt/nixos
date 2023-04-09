{ config }:
let
  inherit (config.myos.data) ports fqdn path;
in
rec {
  mixed-port = ports.clash-meta-mixed;
  tproxy-port = ports.clash-tproxy;

  allow-lan = false;

  ipv6 = true;

  external-controller = "127.0.0.1:${toString ports.clash-meta-api}";

  log-level = "warning";

  mode = "rule";

  dns = {
    enable = true;
    ipv6 = true;
    listen = "0.0.0.0:${toString ports.clash-dns}";

    enhanced-mode = "redir-host";
    # fake-ip-range = "198.18.0.1/16";

    default-nameserver = [
      "223.5.5.5"
    ];

    nameserver = [
      "tls://8.8.4.4#select"
      "tls://1.0.0.1#select"
    ];

    nameserver-policy = {
      "geosite:geolocation-cn" = [
        "114.114.114.114"
        "https://doh.pub/dns-query"
        "https://dns.alidns.com/dns-query"
      ];

    };

    proxy-server-nameserver = [
      "https://doh.pub/dns-query"
    ];

    use-hosts = true;
  };

  proxies = [
    {
      name = "azv6test";
      type = "ss";
      server = config.sops.placeholder.dui_ipv6;
      port = ports.ss1;
      cipher = "chacha20-ietf-poly1305";
      password = config.sops.placeholder.sspass;
      udp = true;
    }
    {
      name = "sswebsoc";
      type = "ss";
      server = "${fqdn.edg}";
      port = 443;
      cipher = "chacha20-ietf-poly1305";
      password = config.sops.placeholder.sspass;
      plugin = "v2ray-plugin";
      plugin-opts = {
        mode = "websocket";
        tls = true;
        host = "${fqdn.edg}";
        path = "${path.ss2}";
      };
    }
  ];

  proxy-providers = {
    mumbai = {
      type = "http";
      url = config.sops.placeholder.clash-provider-mumbai;
      interval = 3600;
      path = "mumbai.yaml";
      health-check = {
        enable = true;
        interval = 600;
        url = "http://www.gstatic.com/generate_204";
      };
    };
  };

  proxy-groups =
    let
      custom-pxs = (map (x: (toString x.name)) proxies);
      providers = builtins.attrNames proxy-providers;
    in
    [
      {
        name = "select";
        type = "select";
        use = providers;
        proxies = custom-pxs ++ [
          "auto"
          "fallback"
          "DIRECT"
        ];
      }
      {
        name = "auto";
        type = "url-test";
        use = providers;
        proxies = custom-pxs;
        interval = 86400;
        url = "http://www.gstatic.com/generate_204";
      }
      {
        name = "fallback";
        type = "fallback";
        use = providers;
        proxies = custom-pxs;
        interval = 7200;
        url = "http://www.gstatic.com/generate_204";
      }
    ];

  rules = [
    "GEOSITE,category-ads-all,REJECT"
    "GEOSITE,geolocation-cn,DIRECT"
    "GEOIP,CN,DIRECT"
    "MATCH,select"
  ];
}
