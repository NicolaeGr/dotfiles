{
  lib,
  config,
  configVars,
  hostName,
  ...
}:
let
  cfg = config.local.platform;
  inherit (lib) mkOption types;

  platformLib = import ./lib.nix {
    inherit lib cfg;
  };
  inherit (platformLib) flat isDomainName;

  portType = types.ints.between 1 65535;

  accessType = types.either (types.enum [
    "public"
    "private"
  ]) (types.listOf types.str);

  domainsByHost = lib.mapAttrs (
    _: es: lib.unique (lib.filter isDomainName (lib.concatMap (e: [ e.n ] ++ e.v.aliases) es))
  ) (lib.groupBy (e: e.svc.host) flat.http);

  internalRecords = map (e: {
    name = e.n;
    fqdn = "${e.n}.${cfg.internalDomain}";
    ip = e.svc.address;
    host = e.svc.host;
    inherit (e) port;
  }) flat.internal;

  endpoints = lib.listToAttrs (
    map (
      r:
      lib.nameValuePair r.name {
        host = r.fqdn;
        inherit (r) port;
      }
    ) internalRecords
  );

  namedServices = lib.mapAttrsToList (name: svc: { inherit name svc; }) (
    lib.filterAttrs (_: s: s.enable) cfg.services
  );

  dups = xs: lib.unique (lib.filter (x: lib.count (y: y == x) xs > 1) xs);

  # Only silent failures: duplicate addresses, server names and internal names.
  checks = [
    {
      assertion = lib.length internalRecords == lib.length (lib.unique (map (r: r.name) internalRecords));
      message = "local.platform: duplicate ingress.internal names: ${
        lib.concatStringsSep ", " (dups (map (r: r.name) internalRecords))
      }";
    }
  ]
  ++
    lib.mapAttrsToList
      (key: es: {
        assertion = lib.length es <= 1;
        message = "local.platform: ${
          lib.concatStringsSep ", " (map (e: "services.${e.name}") es)
        } share host/address ${key}";
      })
      (
        lib.groupBy (e: "${e.svc.host}/${e.svc.address}") (
          lib.filter (e: e.svc.container != null) namedServices
        )
      )
  ++ lib.mapAttrsToList (host: es: {
    assertion = dups (map (e: e.n) es) == [ ];
    message = "local.platform: ${host} serves duplicate names: ${
      lib.concatStringsSep ", " (dups (map (e: e.n) es))
    }";
  }) (lib.groupBy (e: e.svc.host) flat.http);

  pathEntry = types.submodule {
    options = {
      # Null inherits the server-level rules.
      access = mkOption {
        type = types.nullOr accessType;
        default = null;
      };
      extraConfig = mkOption {
        type = types.lines;
        default = "";
      };
    };
  };

  httpEntry = types.submodule {
    options = {
      # Key into the service's `ports`. Null generates no "/" location, so a
      # static-file vhost can use `vhost` alone.
      port = mkOption {
        type = types.nullOr types.str;
        default = "http";
      };
      tls = mkOption {
        type = types.bool;
        default = true;
      };
      access = mkOption {
        type = accessType;
        default = "private";
      };
      aliases = mkOption {
        type = types.listOf types.str;
        default = [ ];
      };
      extraConfig = mkOption {
        type = types.lines;
        default = "";
      };
      proxyExtraConfig = mkOption {
        type = types.lines;
        default = "";
      };
      proxyWebsockets = mkOption {
        type = types.bool;
        default = false;
      };
      paths = mkOption {
        type = types.attrsOf pathEntry;
        default = { };
      };
      # Raw nginx vhost attributes, merged as a second module.
      vhost = mkOption {
        type = types.attrsOf types.unspecified;
        default = { };
      };
    };
  };

  streamEntry = types.submodule {
    options = {
      listen = mkOption { type = portType; };
      port = mkOption { type = types.str; };
      tls = mkOption {
        type = types.bool;
        default = true;
      };
      access = mkOption {
        type = accessType;
        default = "private";
      };
      proxyProtocol = mkOption {
        type = types.bool;
        default = false;
      };
      extraConfig = mkOption {
        type = types.lines;
        default = "";
      };
    };
  };

  internalEntry = types.submodule {
    options.port = mkOption { type = types.str; };
  };

  # Layer-4 ingress for protocols nginx should not proxy (games, databases).
  # With no `listen` the entry only filters forward traffic to a container.
  # With `listen` it also DNATs that port on the router.
  l4Entry = types.submodule {
    options = {
      proto = mkOption {
        type = types.enum [
          "tcp"
          "udp"
        ];
        default = "tcp";
      };
      port = mkOption { type = types.str; };
      listen = mkOption {
        type = types.nullOr portType;
        default = null;
      };
      access = mkOption {
        type = accessType;
        default = "private";
      };
    };
  };

  serviceModule = { ... }: {
    options = {
      host = mkOption { type = types.str; };
      enable = mkOption {
        type = types.bool;
        default = true;
      };
      address = mkOption {
        type = types.str;
        default = "127.0.0.1";
      };
      ports = mkOption {
        type = types.attrsOf portType;
        default = { };
      };
      ingress = {
        http = mkOption {
          type = types.attrsOf httpEntry;
          default = { };
        };
        stream = mkOption {
          type = types.attrsOf streamEntry;
          default = { };
        };
        l4 = mkOption {
          type = types.attrsOf l4Entry;
          default = { };
        };
        internal = mkOption {
          type = types.attrsOf internalEntry;
          default = { };
        };
      };
      container = mkOption {
        type = types.nullOr (
          types.submodule {
            options = {
              mounts = mkOption {
                type = types.attrsOf types.unspecified;
                default = { };
              };
              module = mkOption {
                type = types.deferredModule;
                default = { };
              };
            };
          }
        );
        default = null;
        description = "NixOS container for this service; null means it runs natively.";
      };
    };
  };
in
{
  options.local.platform = {
    acmeHost = mkOption {
      type = types.str;
      default = "electrolit.biz";
    };
    internalDomain = mkOption {
      type = types.str;
      default = "internal";
    };
    privateCidrs = mkOption {
      type = types.listOf types.str;
      default = [
        configVars.net.lan.subnet
        configVars.net.publicIp
      ]
      ++ (configVars.net.tiers.admin or [ ]);
    };
    tiers = mkOption {
      type = types.attrsOf (types.listOf types.str);
      default = configVars.net.tiers or { };
      description = "Named source ranges services can use in `access`.";
    };
    # Tiers that may reach everything. Other tiers only get what individual
    # entries grant, plus nginx on 80/443.
    trustedTiers = mkOption {
      type = types.listOf types.str;
      default = [ "admin" ];
    };
    router = mkOption {
      type = types.bool;
      default = false;
      description = "Generate the inter-zone firewall and port forwarding on this host.";
    };
    wgInterface = mkOption {
      type = types.str;
      default = "wg0";
    };
    svcInterface = mkOption {
      type = types.str;
      default = "br-svc";
    };
    lanInterface = mkOption {
      type = types.str;
      default = "br0";
    };
    services = mkOption {
      type = types.attrsOf (types.submodule serviceModule);
      default = { };
    };

    domainsByHost = mkOption {
      type = types.attrsOf (types.listOf types.str);
      readOnly = true;
    };
    internalRecords = mkOption {
      type = types.listOf types.attrs;
      readOnly = true;
    };
    endpoints = mkOption {
      type = types.attrsOf types.attrs;
      readOnly = true;
    };
    checks = mkOption {
      type = types.listOf types.attrs;
      readOnly = true;
    };
  };

  config = {
    assertions = cfg.checks;

    # Catalog files gate native config with `lib.mkIf (platformOwns "name")`.
    # Service data cannot build a module at merge time: NixOS forces merge
    # lists while it collects definitions, so a config-derived mkMerge
    # recurses.
    _module.args.platformOwns =
      name:
      let
        svc = cfg.services.${name};
      in
      svc.enable && svc.host == hostName;

    local.platform = {
      inherit
        domainsByHost
        internalRecords
        endpoints
        checks
        ;
    };
  };
}
