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

  accessLines =
    {
      atLocation ? false,
      access,
    }:
    let
      cidrs =
        if access == null || access == "public" then
          [ ]
        else if access == "private" then
          cfg.privateCidrs
        else
          access;
    in
    map (c: "allow ${c};") cidrs
    ++ lib.optional (cidrs != [ ]) "deny all;"
    # A location inherits the server rules, so an explicit "public" at
    # location level has to reset them.
    ++ lib.optional (atLocation && access == "public") "allow all;";

  # Server-level headers would be shadowed by the location-level ones emitted
  # below, so per-service header tweaks belong in `proxyExtraConfig`.
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
    hostBridge = "br0";
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
        networking.defaultGateway = configVars.net.gateway;
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

    assertions = [
      {
        assertion = lib.all (n: lib.elem n (cfg.domainsByHost.${hostName} or [ ])) (
          lib.filter isDomainName (lib.attrNames config.services.nginx.virtualHosts)
        );
        message = "nginx serves a name missing from local.platform";
      }
    ];
  };
}
