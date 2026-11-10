{
  pkgs,
  lib,
  self,
  config,
  configVars,
  ...
}:
let
  cfg = config.local.wireguard;
  net = configVars.net;

  platform = config.local.platform;

  webRewrite = domain: [
    "||${domain}^$dnsrewrite=${net.lan.serverIp},client=${net.lan.subnet}"
    "||${domain}^$dnsrewrite=${net.wg.serverIp},client=${net.wg.subnet}"
  ];

  peers = [
    {
      name = "odin";
      key = "DoB3CnXKA7eo+YR7FHzdk9SBzDde4mZBRWWubrSxfTU=";
      ip = "10.100.0.2";
    }
    {
      name = "sweet";
      key = "vaX2WLPn8thbGr+EEpBLpIMlqybc5uokUnhD0e1NmhA=";
      ip = "10.100.0.3";
    }
    {
      name = "phoneAdrian";
      key = "9rMvLrNfoIBT18kycuIpZhNmtjYraJ5ihUahDd5PdSs=";
      ip = "10.100.0.4";
    }
  ];

  wg-peer = pkgs.writeShellApplication {
    name = "wg-peer";
    runtimeInputs = with pkgs; [
      wireguard-tools
      nftables
      coreutils
      qrencode
    ];
    text = ''
      usage() {
        cat >&2 <<'USAGE'
      wg-peer config NAME IP [PUBKEY]   print a client config and the Nix peer entry
      wg-peer elevate IP TTL            temporary admin access, e.g. TTL=8h (lost on reboot)
      wg-peer list                      peers, handshakes, temporary grants
      USAGE
        exit 1
      }

      cmd=''${1:-}
      [ -n "$cmd" ] || usage
      shift

      case "$cmd" in
        config)
          name=''${1:?usage: wg-peer config NAME IP [PUBKEY]}
          ip=''${2:?usage: wg-peer config NAME IP [PUBKEY]}
          given=''${3:-}

          priv=""
          if [ -n "$given" ]; then
            pub=$given
          else
            priv=$(wg genkey)
            pub=$(wg pubkey <<<"$priv")
          fi

          server=$(wg show wg0 public-key)

          if [ -n "$priv" ]; then
            conf=$(printf '[Interface]\nPrivateKey = %s\nAddress = %s/16\nDNS = %s\n\n[Peer]\nPublicKey = %s\nEndpoint = %s\nAllowedIPs = %s\nPersistentKeepalive = 25\n' \
              "$priv" "$ip" "${net.wg.serverIp}" "$server" \
              "${net.wg.endpoint}:${toString cfg.listenPort}" \
              "${net.wg.subnet}, ${net.svc.subnet}, ${net.lan.subnet}")
            printf '%s\n' "$conf"
            qrencode -t ansiutf8 <<<"$conf"
          fi

          printf '\n# add to hosts/lumix/wireguard.nix peers:\n  { name = "%s"; key = "%s"; ip = "%s"; }\n' \
            "$name" "$pub" "$ip"
          ;;

        elevate)
          ip=''${1:?usage: wg-peer elevate IP TTL}
          ttl=''${2:?usage: wg-peer elevate IP TTL}
          nft add element inet tierfw admin-temp "{ $ip timeout $ttl }"
          ;;

        list)
          wg show wg0
          nft list set inet tierfw admin-temp
          ;;

        *) usage ;;
      esac
    '';
  };
in
{
  local.wireguard.enable = true;

  environment.systemPackages = [ wg-peer ];

  sops.secrets.lumix_wg_private_key = {
    sopsFile = (self + "/secrets/wireguard.yaml");
    format = "yaml";
    owner = "systemd-network";
    mode = "0400";
  };

  systemd.network = {
    netdevs."30-wg0" = {
      netdevConfig = {
        Name = "wg0";
        Kind = "wireguard";
      };
      wireguardConfig = {
        PrivateKeyFile = config.sops.secrets.lumix_wg_private_key.path;
        ListenPort = cfg.listenPort;
      };
      wireguardPeers = map (p: {
        PublicKey = p.key;
        AllowedIPs = [ "${p.ip}/32" ];
      }) peers;
    };

    networks."30-wg0" = {
      matchConfig.Name = "wg0";
      address = [ "${net.wg.serverIp}/16" ];
    };
  };

  networking.nftables.tables.wgnat = {
    family = "ip";
    content = ''
      chain post {
        type nat hook postrouting priority srcnat; policy accept;
        oifname "br0" masquerade
      }
    '';
  };

  services.adguardhome = {
    enable = true;

    settings = {
      http = {
        address = "${net.wg.serverIp}:3000";
      };
      dns = {
        bind_addresses = [
          net.wg.serverIp
          net.lan.serverIp
        ];
        port = 53;

        upstream_dns = [
          "https://dns.adguard-dns.com/dns-query"
          "https://freedns.controld.com/p2"
          "https://dnsforge.de/dns-query"
          "https://doh.libredns.gr/noads"
          "https://doh.mullvad.net/dns-query"
        ];

        bootstrap_dns = [
          "9.9.9.9"
          "1.1.1.1"
        ];

        protection_enabled = true;
        filtering_enabled = true;
      };

      user_rules =
        lib.concatMap webRewrite (platform.domainsByHost.lumix or [ ])
        ++ map (r: "||${r.fqdn}^$dnsrewrite=${r.ip}") platform.internalRecords;

      users = [ ];
    };
  };
}
