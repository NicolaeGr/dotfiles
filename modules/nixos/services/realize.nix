{
  config,
  lib,
  pkgs,
  hostName,
  configVars,
  ...
}:
let
  cfg = config.local.platform;

  platformLib = import ./lib.nix {
    inherit lib cfg;
  };
  inherit (platformLib) isDomainName;

  mine = lib.filterAttrs (_: s: s.enable && s.host == hostName) cfg.services;
  mineFlat = sel: lib.filter (e: e.svc.host == hostName) platformLib.flat.${sel};

  httpEntries = mineFlat "http";
  streamEntries = mineFlat "stream";
  l4Entries = mineFlat "l4";

  isPublic = access: access == "public" || (lib.isList access && lib.elem "public" access);

  tierCidrs =
    access:
    lib.concatMap (
      a:
      if lib.hasInfix "/" a || builtins.match "[0-9.]+" a != null then
        a
      else
        cfg.tiers.${a} or (throw "local.platform: unknown tier '${a}' in access")
    ) access;

  accessCidrs =
    access:
    if access == null || isPublic access then
      [ ]
    else if access == "private" then
      cfg.privateCidrs
    else
      tierCidrs access;

  accessLines =
    {
      atLocation ? false,
      access,
    }:
    let
      cidrs = accessCidrs access;
    in
    map (c: "allow ${c};") cidrs
    ++ lib.optional (cidrs != [ ]) "deny all;"
    # A location inherits the server rules, so an explicit "public" at
    # location level has to reset them.
    ++ lib.optional (atLocation && isPublic access) "allow all;";

  proxyHeaders = [
    "proxy_set_header Host $host;"
    "proxy_set_header X-Real-IP $remote_addr;"
    "proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;"
    "proxy_set_header X-Forwarded-Proto $scheme;"
  ];

  mkProxyLocation =
    {
      entry,
      access,
      extra,
    }:
    {
      proxyPass = "http://${entry.svc.address}:${toString entry.port}";
      extraConfig = lib.concatStringsSep "\n" (
        lib.filter (l: l != "") (
          accessLines {
            atLocation = true;
            inherit access;
          }
          ++ proxyHeaders
          ++ [ extra ]
        )
      );
    };

  mkHttpVhost =
    e:
    let
      v = e.v;
    in
    {
      forceSSL = v.tls;
      extraConfig = lib.concatStringsSep "\n" (
        lib.filter (l: l != "") (accessLines { inherit (v) access; } ++ [ v.extraConfig ])
      );
      locations =
        lib.optionalAttrs (e.port != null) {
          "/" =
            mkProxyLocation {
              entry = e;
              access = null;
              extra = v.proxyExtraConfig;
            }
            // {
              inherit (v) proxyWebsockets;
            };
        }
        // lib.mapAttrs (
          _: pv:
          mkProxyLocation {
            entry = e;
            inherit (pv) access;
            extra = pv.extraConfig;
          }
        ) v.paths;
    }
    // lib.optionalAttrs v.tls { useACMEHost = cfg.acmeHost; }
    // lib.optionalAttrs (v.aliases != [ ]) { serverAliases = v.aliases; };

  mkStream =
    e:
    let
      v = e.v;
    in
    lib.concatStringsSep "\n" (
      [
        "server {"
        "    listen ${toString v.listen}${lib.optionalString v.tls " ssl"};"
        "    proxy_pass ${e.svc.address}:${toString e.port};"
      ]
      ++ lib.optional v.proxyProtocol "proxy_protocol on;"
      ++ accessLines { inherit (v) access; }
      ++ lib.optionals v.tls [
        "    ssl_certificate /var/lib/acme/${cfg.acmeHost}/fullchain.pem;"
        "    ssl_certificate_key /var/lib/acme/${cfg.acmeHost}/key.pem;"
        "    ssl_trusted_certificate /var/lib/acme/${cfg.acmeHost}/chain.pem;"
        ""
        "    ssl_protocols TLSv1.2 TLSv1.3;"
      ]
      ++ lib.optionals (v.extraConfig != "") (lib.splitString "\n" (lib.removeSuffix "\n" v.extraConfig))
      ++ [ "}" ]
    );

  mkContainer = s: {
    autoStart = true;
    privateNetwork = true;
    hostBridge = cfg.svcInterface;
    bindMounts = s.container.mounts;
    config =
      { lib, ... }:
      {
        imports = [ s.container.module ];

        # Reuse the host package set so overlay packages stay available
        # inside the container.
        nixpkgs.pkgs = pkgs;

        _module.args = {
          svc = s;
          services = cfg.services;
          endpoints = cfg.endpoints;
          inherit configVars;
        };

        users.users.deploy = {
          isSystemUser = true;
          uid = 1002;
          group = "users";
          extraGroups = [
            "render"
            "video"
          ];
        };
        users.groups.users.gid = 100;

        networking.useHostResolvConf = lib.mkForce false;
        networking.nameservers = [ "1.1.1.1" ];
        # Containers resolve the internal names without a DNS server.
        networking.extraHosts = lib.concatMapStrings (r: "${r.ip} ${r.fqdn}\n") (
          lib.filter (r: r.host == hostName && r.ip != "127.0.0.1") cfg.internalRecords
        );
        networking.defaultGateway = configVars.net.svc.serverIp;
        networking.interfaces.eth0.ipv4.addresses = [
          {
            address = s.address;
            prefixLength = 24;
          }
        ];

        environment.systemPackages = lib.mkBefore [ pkgs.kitty ];
        system.stateVersion = config.system.stateVersion;
      };
  };

  # The router marks traffic it allows and lets the NixOS firewall accept the
  # mark. Everything else from the WG interface is dropped before nixos-fw
  # gets a chance to apply its port rules.
  trustedCidrs = lib.concatMap (
    t: cfg.tiers.${t} or (throw "local.platform: unknown trusted tier '${t}'")
  ) cfg.trustedTiers;

  nftList = xs: "{ ${lib.concatStringsSep ", " xs} }";

  saddrOf =
    access:
    let
      cidrs = accessCidrs access;
    in
    lib.optionalString (cidrs != [ ]) "ip saddr ${nftList cidrs} ";

  l4Forward =
    e:
    "iifname \"${cfg.wgInterface}\" ${saddrOf e.v.access}ip daddr ${e.svc.address} ${e.v.proto} dport ${toString e.port} accept";

  dnatEntries = lib.filter (e: e.v.listen != null) l4Entries;

  # Stream listeners get past the WG input filter so nginx can apply the
  # entry's own allow/deny lines.
  streamMark = lib.optionalString (streamEntries != [ ]) (
    "iifname \"${cfg.wgInterface}\" tcp dport { ${
      lib.concatStringsSep ", " (map (e: toString e.v.listen) streamEntries)
    } } meta mark set 0x100"
  );

  dnatRule =
    e:
    "${saddrOf e.v.access}${e.v.proto} dport ${toString e.v.listen} dnat ip to ${e.svc.address}:${toString e.port}";

  dups = xs: lib.unique (lib.filter (x: lib.count (y: y == x) xs > 1) xs);
in
{
  config = {
    containers = lib.mapAttrs (_: mkContainer) (lib.filterAttrs (_: s: s.container != null) mine);

    services.nginx = {
      virtualHosts = lib.listToAttrs (
        map (
          e:
          lib.nameValuePair e.n (
            lib.mkMerge [
              (mkHttpVhost e)
              e.v.vhost
            ]
          )
        ) httpEntries
      );
    }
    // lib.optionalAttrs (streamEntries != [ ]) {
      streamConfig = lib.concatStringsSep "\n" (map mkStream streamEntries);
    };

    networking.firewall.allowedTCPPorts = map (e: e.v.listen) streamEntries;

    # Accept what the tier chain marked. filterForward stays off, so tierfw is
    # the only forward chain and its own accepts/drops are enough there.
    networking.firewall.extraInputRules = lib.mkIf cfg.router "meta mark 0x100 accept";

    networking.nftables.tables.tierfw = lib.mkIf cfg.router {
      family = "inet";
      content = ''
        set admin-temp {
          type ipv4_addr
          flags timeout
        }

        chain input {
          type filter hook input priority -10; policy accept;
          ct state established,related meta mark set 0x100
          iifname "${cfg.wgInterface}" ip saddr @admin-temp meta mark set 0x100
          iifname "${cfg.wgInterface}" ip saddr ${nftList trustedCidrs} meta mark set 0x100
          iifname "${cfg.wgInterface}" tcp dport { 80, 443 } meta mark set 0x100
          ${streamMark}
          iifname "${cfg.wgInterface}" udp dport 53 meta mark set 0x100
          iifname "${cfg.wgInterface}" tcp dport 53 meta mark set 0x100
          iifname "${cfg.wgInterface}" meta mark != 0x100 drop
        }

        chain forward {
          type filter hook forward priority -10; policy accept;
          iifname "${cfg.wgInterface}" ct state established,related accept
          iifname "${cfg.wgInterface}" ip saddr @admin-temp accept
          iifname "${cfg.wgInterface}" ip saddr ${nftList trustedCidrs} accept
          ${lib.concatStringsSep "\n          " (map l4Forward l4Entries)}
          iifname "${cfg.wgInterface}" drop

          # Containers may reach the internet through lumix, not the LAN. A
          # LAN host that routes the service subnet here may still connect.
          iifname "${cfg.svcInterface}" oifname "${cfg.lanInterface}" ip daddr ${configVars.net.lan.subnet} ct state established,related accept
          iifname "${cfg.svcInterface}" oifname "${cfg.lanInterface}" ip daddr ${configVars.net.lan.subnet} drop
        }
      '';
    };

    networking.nftables.tables.platform-dnat = lib.mkIf (cfg.router && dnatEntries != [ ]) {
      family = "ip";
      content = ''
        chain prerouting {
          type nat hook prerouting priority dstnat; policy accept;
          ${lib.concatStringsSep "\n          " (map dnatRule dnatEntries)}
        }
      '';
    };

    assertions = [
      {
        assertion = lib.all (n: lib.elem n (cfg.domainsByHost.${hostName} or [ ])) (
          lib.filter isDomainName (lib.attrNames config.services.nginx.virtualHosts)
        );
        message = "nginx serves a name missing from local.platform";
      }
      {
        assertion = lib.all (e: e.svc.address != "127.0.0.1") l4Entries;
        message = "local.platform: ingress.l4 needs a routable service address, not loopback";
      }
      {
        assertion = dups (map (e: e.v.listen) dnatEntries) == [ ];
        message = "local.platform: duplicate ingress.l4 listen ports: ${
          lib.concatStringsSep ", " (map toString (dups (map (e: e.v.listen) dnatEntries)))
        }";
      }
    ];
  };
}
