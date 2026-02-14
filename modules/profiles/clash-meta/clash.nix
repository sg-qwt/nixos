{ config, pkgs, interface, self }:
let
  inherit (self.shared-data) ports fqdn path dui-ipv4 xun-ipv4;
in
rec {
  mixed-port = ports.clash-meta-mixed;
  ipv6 = true;
  allow-lan = false;
  external-controller = "0.0.0.0:${toString ports.clash-meta-api}";
  secret = config.vaultix.placeholder.clash-secret;
  log-level = "warning";

  mode = "rule";
  find-process-mode = "always";
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
    exclude-interface = [
      config.services.tailscale.interfaceName
      "tun163"
    ];
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
      "+.tailscale.com"
      "+.tailscale.io"
      "+.pool.ntp.org"
      "+.uu.163.com"
      "ps.res.netease.com"
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
      server = dui-ipv4;
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
      name = "vless-warp";
      type = "wireguard";
      server = "engage.cloudflareclient.com";
      port = 2408;
      ip = "172.16.0.2/32";
      ipv6 = "2606:4700:110:8917:8d18:1f95:291e:3c2e/128";
      private-key = config.vaultix.placeholder.warp-key;
      public-key = "bmXOC+F1FxEMF9dyiK2H5/1SUtzH0JuVo51h2wPfgyo=";
      udp = true;
      mtu = 1280;
      remote-dns-resolve = true;
      dns = [
        "https://dns.cloudflare.com/dns-query"
      ];
      dialer-proxy = "vless";
    }
    {
      name = "sstls";
      type = "ss";
      server = xun-ipv4;
      port = ports.sstls;
      cipher = "2022-blake3-aes-128-gcm";
      password = config.vaultix.placeholder.sing-shadow;
      client-fingerprint = "chrome";
      plugin = "shadow-tls";
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
        name = "poly";
        type = "select";
        proxies = [
          "sstls"
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
    "DOMAIN-SUFFIX,steamchina.com,DIRECT"
    "DOMAIN-SUFFIX,polymarket.com,poly"
    "GEOSITE,category-ads-all,REJECT"
    "GEOSITE,openai,select"
    "GEOSITE,geolocation-cn,DIRECT"
    "GEOIP,CN,DIRECT"
    "MATCH,select"
  ];
}
