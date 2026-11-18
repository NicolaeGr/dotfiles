{ lib, cfg }:
let
  isIpv4 = s: builtins.match "[0-9.]+" s != null;

  isDomainName = n: lib.hasInfix "." n && !(isIpv4 n);

  portOf =
    sn: svc: p:
    if p == null then
      null
    else if svc.ports ? ${p} then
      svc.ports.${p}
    else
      throw "local.platform.services.${sn}: ingress references undefined port '${p}'";

  enabled = lib.filterAttrs (_: s: s.enable) cfg.services;

  dups = xs: lib.unique (lib.filter (x: lib.count (y: y == x) xs > 1) xs);

  # [{ sn, svc, n, v, port }] for one ingress kind over all enabled services.
  each =
    sel:
    lib.concatLists (
      lib.mapAttrsToList (
        sn: svc:
        lib.mapAttrsToList (n: v: {
          inherit
            sn
            svc
            n
            v
            ;
          port = portOf sn svc v.port;
        }) (sel svc)
      ) enabled
    );
in
{
  inherit
    isDomainName
    isIpv4
    portOf
    enabled
    dups
    ;

  flat = lib.genAttrs [ "http" "stream" "l4" "internal" ] (kind: each (s: s.ingress.${kind}));
}
