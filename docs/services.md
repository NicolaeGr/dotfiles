# Service containers and ingress

Everything `lumix` runs lives in one catalog: `modules/nixos/services/catalog/`, one file per service. Every host imports the catalog through `hosts/_common`, so all three evaluate the same data. Only the host named in `local.platform.services.<name>.host` turns an entry into containers, nginx vhosts or systemd units.

| File                                 | Holds                                                     |
| ------------------------------------ | --------------------------------------------------------- |
| `modules/nixos/services/options.nix` | Model, settings, and the read-only outputs                |
| `modules/nixos/services/realize.nix` | Containers, vhosts, stream blocks, firewall, for one host |
| `modules/nixos/services/lib.nix`     | `portOf`, `isDomainName`, and the flat ingress lists      |
| `modules/nixos/services/catalog/`    | One entry per service                                     |

Keep the top level of a catalog file pure. It may use `lib`, `configVars` and plain values. Anything that needs `pkgs` or host config goes inside `container.module` or behind `platformOwns`.

## Anatomy of an entry

`catalog/navidrome.nix`:

```nix
{
  local.platform.services.navidrome = {
    host = "lumix";
    address = "192.168.100.13";
    ports.http = 4533;

    ingress.http."music.electrolit.biz" = {
      port = "http";
      proxyWebsockets = true;
    };

    container = {
      mounts."/storage" = {
        hostPath = "/storage";
        isReadOnly = true;
      };

      module = { svc, ... }: {
        services.navidrome = {
          enable = true;
          openFirewall = true;
          user = "deploy";
          group = "users";
          settings = {
            Address = "0.0.0.0";
            Port = svc.ports.http;
            MusicFolder = "/storage/media/music";
          };
        };
      };
    };
  };
}
```

| Field              | Meaning                                                                                                                |
| ------------------ | ---------------------------------------------------------------------------------------------------------------------- |
| `host`             | Which machine realizes the entry. `zoln` and `odin` still read the data.                                               |
| `enable`           | Turns the whole entry off, data included.                                                                              |
| `address`          | Container address on `br0`. The default is `127.0.0.1`, so a container needs an explicit address to be reachable.      |
| `ports`            | Named ports. Ingress refers to these names, never to numbers.                                                          |
| `container.mounts` | Passed straight to the container's `bindMounts`. Keys are container paths.                                             |
| `container.module` | A NixOS module evaluated inside the container. It gets `pkgs`, `lib`, `svc`, `services`, `endpoints` and `configVars`. |

The container itself is named after the service key. That name appears in the systemd unit (`container@navidrome`), in `/etc/nixos-containers/`, and in `nixos-container run`.

## Adding one

1. Copy an existing file in `catalog/` and rename it. `scanPaths` picks it up automatically.
2. Set `host`, pick an unused `address` on `192.168.100.0/24`, and name the ports.
3. Write `container.module` as a normal NixOS module. Use `svc.ports.<name>` instead of repeating numbers.
4. Grant inbound access inside the container with `openFirewall = true` or an explicit `networking.firewall.allowedTCPPorts`.
5. Describe how traffic arrives. Any served name must appear as an `ingress.http` key, or the build fails with `nginx serves a name missing from local.platform`.

Check the result without building the machine:

```sh
nix eval --json .#nixosConfigurations.lumix.config.containers --apply builtins.attrNames
nix eval --json .#nixosConfigurations.lumix.config.containers.<name>.path.drvPath
nix build '.#nixosConfigurations.lumix.config.environment.etc."nginx/nginx.conf".source'
```

A container module runs with the host's package set (`nixpkgs.pkgs = pkgs`), so overlay packages such as `pkgs.soularr` stay available inside. The wrapper also creates the `deploy` user with uid 1002, group `users` gid 100, and the `render` and `video` groups.

## Talking to other services

Every container is a private network on `br0` with a static address. Two containers on the same machine reach each other directly at `address:port`. Nothing else is needed, no port publishing, no host loopback.

The serving container still has to accept the connection. PostgreSQL allows the LAN and WireGuard subnets in `authentication`; a smaller service usually just sets `openFirewall = true`.

Every container gets an `/etc/hosts` entry for each internal record on its own machine, so the name resolves without a DNS server:

```
DB_HOST=pg.internal
DB_PORT=5432
```

The address still works and is what the record contains. `domainsByHost` and `internalRecords` are exported on every host, `hosts/zoln/dns.nix` writes them into `/etc/hosts`, and AdGuard rewrites them for VPN clients. `endpoints.<name>` gives a container module the name and port, which is why `pg-newdb` prints `postgres://user:pw@pg.internal:5432/user` and why `mnemo` sets `PGHOST` from `endpoints.pg.host`.

## Kinds of ingress

There are three, and they do not overlap.

| Kind       | Creates                                      | Use for                                      |
| ---------- | -------------------------------------------- | -------------------------------------------- |
| `http`     | nginx vhost with TLS and a proxy to the port | Web apps, dashboards, anything browsers open |
| `stream`   | nginx `stream` server on a raw port          | TLS passthrough for non-HTTP protocols       |
| `internal` | A name and endpoint, no nginx                | Databases and other services reached by name |

### HTTP

```nix
ingress.http."jf.electrolit.biz" = {
  port = "http";            # key in `ports`; null means no generated "/" location
  tls = true;               # wildcard certificate, forceSSL
  access = "public";        # or "private", or a list of CIDRs
  aliases = [ ];            # extra server names
  proxyWebsockets = false;
  proxyExtraConfig = "";    # appended inside the generated "/" location
  extraConfig = "";         # appended at server level
  paths."/socket" = { ... };
  vhost = { };              # raw nginx attrs, merged as a module
};
```

Private is the default. A private vhost gets `allow` lines for the LAN, the WireGuard subnet and the public address, then `deny all`. Public emits no rules, so nginx allows everyone. `tls = false` serves plain HTTP, which is what `bit.electrolit.biz` does because it never leaves the LAN.

The generated `/` location sets `proxy_set_header Host`, `X-Real-IP`, `X-Forwarded-For` and `X-Forwarded-Proto`, then appends `proxyExtraConfig`. Headers at server level would be shadowed by these, which is why per-service header tweaks belong in `proxyExtraConfig`. Use `extraConfig` for server-level directives such as `client_max_body_size` or `add_header`.

### Stream

```nix
ingress.stream.irc = {
  listen = 6697;            # host port, opened in the firewall
  port = "irc";             # container port
  tls = true;               # certificate from acmeHost
  proxyProtocol = true;
  access = [ "192.168.100.0/24" "10.100.0.0/24" ];
  extraConfig = "ssl_ciphers HIGH:!aNULL:!MD5;";
};
```

The stream port is added to `networking.firewall.allowedTCPPorts` automatically. Keep `access` narrow: a stream listener is reachable by anything that reaches the host.

### Internal

```nix
ingress.internal.pg.port = "postgres";
```

This produces an `internalRecords` entry, `pg.internal` pointing at the service address and the resolved port, and an `endpoints.pg` value for container modules. It creates no nginx config. An internal record for a loopback address is useless to other machines, so give the service a real address.

## Splitting a vhost by path

A single hostname can apply different policies per location:

```nix
ingress.http."obsidian.electrolit.biz" = {
  port = "http";
  access = "public";
  proxyWebsockets = true;
  proxyExtraConfig = "client_max_body_size 100M;";
  paths."/_utils/" = {
    access = "private";
  };
};
```

A location inherits the server-level rules unless it defines its own. `access = "public"` at path level therefore emits `allow all;` to reset them; `access = null`, the default, keeps inheritance. Path locations proxy to the entry's port and keep the original URI, so `/_utils/` reaches CouchDB as `/_utils/...` without an explicit URI in `proxy_pass`.

## Hand-written vhosts

When nginx needs more than the model generates, set `port = null` and put the vhost in `vhost`. `vhost` is merged as a second module, so its `extraConfig` and `locations` combine with the generated ones instead of replacing them. The only current user is the static site:

```nix
ingress.http."electrolit.biz" = {
  port = null;
  aliases = [ "www.electrolit.biz" configVars.net.lan.serverIp configVars.net.wg.serverIp ];
  vhost.locations."/" = {
    root = ./.;
    index = "index.html";
    extraConfig = "default_type text/html;";
  };
};
```

IP aliases stay in `serverAliases` for nginx but are filtered out of `domainsByHost`, so they never reach DNS.

## Native services

Not everything belongs in a container. A native service keeps its entry but defines its config on the host, gated by `platformOwns`:

```nix
{
  config = lib.mkMerge [
    {
      local.platform.services.expense = {
        host = "lumix";
        ports.http = 9000;
        ingress.http."expense.electrolit.biz".port = "http";
      };
    }
    (lib.mkIf (platformOwns "expense") {
      systemd.services.expensetracker = { /* ... */ };
    })
  ];
}
```

The `mkMerge` is required because a module cannot mix a top-level `local` attribute with an explicit `config`. Do not build the native config as one attrset computed from `config`; NixOS forces merge lists while it collects definitions, and that recurses.

## What the model checks

`local.platform.checks` runs on every host, so a bad entry fails `zoln` and `odin` too:

- two containerized services on the same host with the same address,
- two vhosts on the same host serving the same name,
- two `ingress.internal` entries with the same name.

`realize.nix` adds one more: every domain-shaped `server_name` on the machine must come from an entry's `ingress.http` key or `aliases`.
