{ config, pkgs }:
let
  inherit (config.myos.data) ports fqdn path;
in
rec {
  mixed-port = ports.clash-meta-mixed;
  tproxy-port = ports.clash-tproxy;

  allow-lan = false;

  ipv6 = false;

  external-controller = "0.0.0.0:${toString ports.clash-meta-api}";
  secret = config.sops.placeholder.clash-secret;

  external-ui = "${pkgs.metacubexd}";

  log-level = "warning";

  mode = "rule";

  sniffer = {
    enable = true;
  };

  dns = {
    enable = true;
    ipv6 = false;
    listen = "0.0.0.0:${toString ports.clash-dns}";

    enhanced-mode = "redir-host";
    # fake-ip-range = "198.18.0.1/16";

    default-nameserver = [
      "223.5.5.5"
      "114.114.114.114"
    ];

    nameserver = [
      "tls://8.8.4.4#select"
      "tls://1.0.0.1#select"
    ];

    nameserver-policy = {
      "geosite:cn" = [
        "114.114.114.114"
        "https://doh.pub/dns-query"
        "https://dns.alidns.com/dns-query"
      ];

    };

    use-hosts = true;
  };

  proxies = [
    {
      name = "wgteam";
      type = "wireguard";
      server = "engage.cloudflareclient.com";
      port = 2408;
      ip = "172.16.0.2";
      ipv6 = "2606:4700:110:8410:f35c:f27f:d43e:b299";
      private-key = config.sops.placeholder.wgteam;
      public-key = "bmXOC+F1FxEMF9dyiK2H5/1SUtzH0JuVo51h2wPfgyo=";
      udp = true;
      mtu = 1420;
      # dialer-proxy = "vless";
    }
    {
      name = "vless";
      type = "vless";
      server = config.sops.placeholder.dui_ipv4;
      port = ports.https;
      uuid = config.sops.placeholder.sing-vless-uuid;
      network = "tcp";
      tls = true;
      udp = true;
      flow = "xtls-rprx-vision";
      servername = config.myos.singbox.sni;
      reality-opts = {
        public-key = "MaT4kg5zs3YFoMa6X4N_EcQJkKJ67Q-vp5wKAOS5YBk";
        short-id = "fdb1";
      };
      client-fingerprint = "chrome";
    }
    {
      name = "sstls";
      type = "ss";
      server = config.sops.placeholder.xun_ipv4;
      port = ports.sstls;
      cipher = "2022-blake3-aes-128-gcm";
      password = config.sops.placeholder.sing-shadow;
      plugin = "shadow-tls";
      client-fingerprint = "chrome";
      plugin-opts = {
        host = config.myos.singbox.sni2;
        password = config.sops.placeholder.sing-shadow-tls;
        version = 3;
      };
    }
  ];

  # proxy-providers = {
  #   # mumbai = {
  #   #   type = "http";
  #   #   url = config.sops.placeholder.clash-provider-mumbai;
  #   #   interval = 3600;
  #   #   path = "mumbai.yaml";
  #   #   health-check = {
  #   #     enable = true;
  #   #     interval = 600;
  #   #     url = "http://www.gstatic.com/generate_204";
  #   #   };
  #   # };
  # };
  proxy-providers = { };

  proxy-groups =
    let
      custom-pxs = (map (x: (toString x.name)) proxies);
      providers = builtins.attrNames proxy-providers;
      build-group = attr:
        if (providers == [ ])
        then attr
        else attr // { use = providers; };
    in
    [
      (build-group {
        name = "select";
        type = "select";
        proxies = custom-pxs ++ [
          "auto"
          "fallback"
          "DIRECT"
        ];
      })

      (build-group {
        name = "auto";
        type = "url-test";
        proxies = custom-pxs;
        interval = 86400;
        url = "http://www.gstatic.com/generate_204";
      })

      (build-group {
        name = "fallback";
        type = "fallback";
        proxies = custom-pxs;
        interval = 7200;
        url = "http://www.gstatic.com/generate_204";
      })
    ];

  rules = [
    # "DOMAIN-SUFFIX,${fqdn.edg},DIRECT"
    "AND,((DOMAIN-SUFFIX,${fqdn.edg}),(DST-PORT,22)),DIRECT"
    "GEOSITE,category-ads-all,REJECT"
    "GEOSITE,openai,select"
    "GEOSITE,geolocation-cn,DIRECT"
    "GEOIP,CN,DIRECT"
    "MATCH,select"
  ];
}
