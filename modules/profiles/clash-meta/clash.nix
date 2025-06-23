{ config, pkgs, interface }:
let
  inherit (config.myos.data) ports fqdn path;
in
rec {
  mixed-port = ports.clash-meta-mixed;
  ipv6 = true;
  allow-lan = false;
  external-controller = "0.0.0.0:${toString ports.clash-meta-api}";
  secret = config.vaultix.placeholder.clash-secret;
  log-level = "warning";

  mode = "rule";
  find-process-mode = "strict";
  geodata-mode = true;
  global-client-fingerprint = "chrome";

  profile = {
    store-selected = true;
    store-fake-ip = true;
  };

  sniffer = {
    enable = true;
    sniff = {
      HTTP = {
        ports = [ 80 "8080-8880" ];
        override-destination = true;
      };
      TLS = {
        ports = [ 443 8443 ];
      };
      QUIC = {
        ports = [ 443 8443 ];
      };
    };
  };

  tun = {
    enable = true;
    stack = "mixed";
    device = interface;
    dns-hijack = [
      "any:53"
      "tcp://any:53"
    ];
    auto-route = true;
    auto-redirect = true;
    auto-detect-interface = true;
  };

  dns = {
    enable = true;
    ipv6 = true;
    use-hosts = true;
    enhanced-mode = "fake-ip";
    respect-rules = true;
    fake-ip-filter = [
      "*"
      "+.lan"
      "+.local"
    ];

    nameserver = [
      "tls://8.8.4.4#select"
      "tls://1.0.0.1#select"
    ];

    proxy-server-nameserver = [
      "https://doh.pub/dns-query"
    ];
    nameserver-policy = {
      "geosite:cn,private" = [
        "https://doh.pub/dns-query"
        "https://dns.alidns.com/dns-query"
      ];
      "geosite:geolocation-!cn" = [
        "https://dns.cloudflare.com/dns-query"
        "https://dns.google/dns-query"
      ];
    };
  };

  proxies = [
    {
      name = "vless";
      type = "vless";
      server = config.vaultix.placeholder.dui-ipv4;
      port = ports.https;
      uuid = config.vaultix.placeholder.sing-vless-uuid;
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
      server = config.vaultix.placeholder.xun-ipv4;
      port = ports.sstls;
      cipher = "2022-blake3-aes-128-gcm";
      password = config.vaultix.placeholder.sing-shadow;
      plugin = "shadow-tls";
      client-fingerprint = "chrome";
      plugin-opts = {
        host = config.myos.singbox.sni2;
        password = config.vaultix.placeholder.sing-shadow-tls;
        version = 3;
      };
    }
  ];

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
    "DOMAIN-SUFFIX,cm.steampowered.com,DIRECT"
    "DOMAIN-SUFFIX,steamserver.net,DIRECT"
    "GEOSITE,category-ads-all,REJECT"
    "GEOSITE,openai,select"
    "GEOSITE,geolocation-cn,DIRECT"
    "GEOIP,CN,DIRECT"
    "MATCH,select"
  ];
}
