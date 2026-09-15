{
  config,
  pkgs,
  interface,
  self,
}:
let
  inherit (self.shared-data) ports;
  inherit (self.tfo) fqdn az-ips;
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

  profile = {
    store-selected = true;
    store-fake-ip = true;
  };

  sniffer = {
    enable = true;
    sniff = {
      HTTP = {
        ports = [
          80
          "8080-8880"
        ];
        override-destination = true;
      };
      TLS = {
        ports = [
          443
          8443
        ];
      };
      QUIC = {
        ports = [
          443
          8443
        ];
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
      "veth-uu-host"
    ];
  };

  dns = {
    enable = true;
    ipv6 = true;
    use-hosts = true;
    enhanced-mode = "fake-ip";
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
    default-nameserver = [
      "tls://223.5.5.5"
      "tls://223.6.6.6"
    ];
    nameserver = [
      "https://doh.pub/dns-query"
      "https://dns.alidns.com/dns-query"
    ];
  };

  proxies =
    let
      mkVariants =
        {
          type,
          hostname,
          settings,
          variantSettings ? (_: { }),
        }:
        map
          (
            family:
            settings
            // {
              name = "${type}-${hostname}-v${family}";
              server = az-ips."${hostname}"."ipv${family}";
            }
            // variantSettings family
          )
          [
            "4"
            "6"
          ];

      anytls = mkVariants {
        type = "anytls";
        hostname = "rocky";
        settings = {
          type = "anytls";
          port = ports.anytls;
          password = config.vaultix.placeholder.sing-pass;
          client-fingerprint = "chrome";
          udp = true;
          tls = true;
          sni = fqdn.edg;
          alpn = [ "h2" ];
          skip-cert-verify = false;
        };
      };

      hy = mkVariants {
        type = "hysteria2";
        hostname = "just";
        settings = {
          type = "hysteria2";
          port = ports.https;
          password = config.vaultix.placeholder.sing-hy;
          up = "10 Mbps";
          down = "10 Mbps";
          obfs = "salamander";
          obfs-password = config.vaultix.placeholder.sing-hy;
          sni = fqdn.cybcc;
          alpn = [ "h3" ];
        };
      };

      sstls = mkVariants {
        type = "ss";
        hostname = "puer";
        settings = {
          type = "ss";
          port = ports.sstls;
          cipher = "2022-blake3-aes-128-gcm";
          password = config.vaultix.placeholder.sing-shadow;
          client-fingerprint = "chrome";
          plugin = "shadow-tls";
          plugin-opts = {
            host = config.myos.singbox.sni2;
            password = config.vaultix.placeholder.sing-pass;
            version = 3;
          };
        };
      };

      masque = {
        name = "masque";
        type = "masque";
        server = "162.159.198.2";
        port = 443;
        ip = "172.16.0.2";
        ipv6 = "2606:4700:110:8b70:fdc8:915f:21c7:daab";
        private-key = config.vaultix.placeholder.masque-key;
        public-key = "MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEIaU7MToJm9NKp8YfGxR6r+/h4mcG\n7SxI8tsW8OR1A5tv/zCzVbCRRh2t87/kxnP6lAy0lkr7qYwu+ox+k3dr6w==";
        udp = true;
        mtu = 1280;
        remote-dns-resolve = true;
        dns = [
          "1.1.1.1"
          "8.8.8.8"
        ];
        dialer-proxy = "proxies-front";
      };

    in
    anytls ++ sstls ++ hy ++ [ masque ];

  proxy-groups =
    let
      custom-pxs = proxies |> map (x: toString x.name) |> builtins.filter (x: x != "masque");
    in
    [
      {
        name = "proxies-front";
        type = "select";
        proxies = custom-pxs;
      }

      {
        name = "select";
        type = "select";
        proxies = custom-pxs ++ [
          "masque"
          "auto"
          "fallback"
          "DIRECT"
        ];
      }

      {
        name = "maybe";
        type = "select";
        proxies = [
          "DIRECT"
          "select"
        ];
        default-selected = "DIRECT";
      }

      {
        name = "openai";
        type = "select";
        proxies = custom-pxs;
        default-selected = "ss-puer-v6";
      }

      {
        name = "auto";
        type = "url-test";
        proxies = custom-pxs;
        interval = 86400;
        url = "http://www.gstatic.com/generate_204";
      }

      {
        name = "fallback";
        type = "fallback";
        proxies = custom-pxs;
        interval = 7200;
        url = "http://www.gstatic.com/generate_204";
      }
    ];

  rules = [
    # "DOMAIN-SUFFIX,${fqdn.edg},DIRECT"
    "AND,((DOMAIN-SUFFIX,${fqdn.edg}),(DST-PORT,22)),DIRECT"
    "DOMAIN-SUFFIX,cm.steampowered.com,DIRECT"
    "DOMAIN-SUFFIX,steamserver.net,DIRECT"
    "DOMAIN-SUFFIX,steamchina.com,DIRECT"

    "DOMAIN-SUFFIX,r2.cloudflarestorage.com,maybe"
    "DOMAIN-SUFFIX,cache.nixos.org,maybe"
    "DOMAIN-SUFFIX,audio-fa.scdn.co,maybe"

    "DOMAIN-SUFFIX,bambulab.com,select"
    "DOMAIN-SUFFIX,makerworld.com,select"
    "DOMAIN-SUFFIX,makerworld.bblmw.com,select"
    # "DOMAIN-SUFFIX,polymarket.com,anytls"
    "DOMAIN-SUFFIX,openai.com,openai"
    "DOMAIN-SUFFIX,chatgpt.com,openai"
    "GEOSITE,category-ads-all,REJECT"
    "GEOSITE,openai,select"
    "GEOSITE,geolocation-cn,DIRECT"
    "GEOIP,CN,DIRECT"
    "MATCH,select"
  ];
}
