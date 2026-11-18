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
  inherit (platformLib) flat isDomainName dups;

  mkOpt = type: default: mkOption { inherit type default; };
  mkReq = type: mkOption { inherit type; };
  mkOptDesc =
    type: default: description:
    mkOption { inherit type default description; };
  mkReadOnly =
    type:
    mkOption {
      inherit type;
      readOnly = true;
    };

  portType = types.ints.between 1 65535;

  accessType = types.either (types.enum [
    "public"
    "private"
  ]) (types.listOf types.str);

  accessOpt = mkOpt accessType "private";
  tlsOpt = mkOpt types.bool true;
  linesOpt = mkOpt types.lines "";

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

  namedServices = lib.mapAttrsToList (name: svc: { inherit name svc; }) platformLib.enabled;

  duplicateCheck = label: names: {
    assertion = dups names == [ ];
    message = "local.platform: ${label}: ${lib.concatStringsSep ", " (dups names)}";
  };

  # Only silent failures: duplicate addresses, server names and internal names.
  checks = [
    (duplicateCheck "duplicate ingress.internal names" (map (r: r.name) internalRecords))
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
  ++ lib.mapAttrsToList (
    host: es: duplicateCheck "${host} serves duplicate names" (map (e: e.n) es)
  ) (lib.groupBy (e: e.svc.host) flat.http);

  pathEntry = types.submodule {
    options = {
      # Null inherits the server-level rules.
      access = mkOpt (types.nullOr accessType) null;
      extraConfig = linesOpt;
    };
  };

  httpEntry = types.submodule {
    options = {
      # Key into the service's `ports`. Null generates no "/" location, so a
      # static-file vhost can use `vhost` alone.
      port = mkOpt (types.nullOr types.str) "http";
      tls = tlsOpt;
      access = accessOpt;
      aliases = mkOpt (types.listOf types.str) [ ];
      extraConfig = linesOpt;
      proxyExtraConfig = linesOpt;
      proxyWebsockets = mkOpt types.bool false;
      paths = mkOpt (types.attrsOf pathEntry) { };
      # Raw nginx vhost attributes, merged as a second module.
      vhost = mkOpt (types.attrsOf types.unspecified) { };
    };
  };

  streamEntry = types.submodule {
    options = {
      listen = mkReq portType;
      port = mkReq types.str;
      tls = tlsOpt;
      access = accessOpt;
      proxyProtocol = mkOpt types.bool false;
      extraConfig = linesOpt;
    };
  };

  internalEntry = types.submodule {
    options.port = mkReq types.str;
  };

  # Layer-4 ingress for protocols nginx should not proxy (games, databases).
  # With no `listen` the entry only filters forward traffic to a container.
  # With `listen` it also DNATs that port on the router.
  l4Entry = types.submodule {
    options = {
      proto = mkOpt (types.enum [
        "tcp"
        "udp"
      ]) "tcp";
      port = mkReq types.str;
      listen = mkOpt (types.nullOr portType) null;
      access = accessOpt;
    };
  };

  serviceModule = {
    options = {
      host = mkReq types.str;
      enable = mkOpt types.bool true;
      address = mkOpt types.str "127.0.0.1";
      ports = mkOpt (types.attrsOf portType) { };
      ingress = {
        http = mkOpt (types.attrsOf httpEntry) { };
        stream = mkOpt (types.attrsOf streamEntry) { };
        l4 = mkOpt (types.attrsOf l4Entry) { };
        internal = mkOpt (types.attrsOf internalEntry) { };
      };
      container = mkOptDesc (types.nullOr (
        types.submodule {
          options = {
            mounts = mkOpt (types.attrsOf types.unspecified) { };
            module = mkOpt types.deferredModule { };
          };
        }
      )) null "NixOS container for this service; null means it runs natively.";
    };
  };
in
{
  options.local.platform = {
    acmeHost = mkOpt types.str "electrolit.biz";
    internalDomain = mkOpt types.str "internal";
    privateCidrs = mkOpt (types.listOf types.str) (
      [
        configVars.net.lan.subnet
        configVars.net.publicIp
      ]
      ++ (configVars.net.tiers.admin or [ ])
    );
    tiers = mkOptDesc (types.attrsOf (types.listOf types.str)) (configVars.net.tiers or { }
    ) "Named source ranges services can use in `access`.";
    # Tiers that may reach everything. Other tiers only get what individual
    # entries grant, plus nginx on 80/443.
    trustedTiers = mkOpt (types.listOf types.str) [ "admin" ];
    router =
      mkOptDesc types.bool false
        "Generate the inter-zone firewall and port forwarding on this host.";
    wgInterface = mkOpt types.str "wg0";
    svcInterface = mkOpt types.str "br-svc";
    lanInterface = mkOpt types.str "br0";
    services = mkOpt (types.attrsOf (types.submodule serviceModule)) { };

    domainsByHost = mkReadOnly (types.attrsOf (types.listOf types.str));
    internalRecords = mkReadOnly (types.listOf types.attrs);
    endpoints = mkReadOnly (types.attrsOf types.attrs);
    checks = mkReadOnly (types.listOf types.attrs);
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
