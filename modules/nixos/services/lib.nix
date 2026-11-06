{ lib, cfg }:
let
  isDomainName = n: lib.hasInfix "." n && builtins.match "[0-9.]+" n == null;

  portOf =
    sn: svc: p:
    if p == null then
      null
    else if svc.ports ? ${p} then
      svc.ports.${p}
    else
      throw "local.platform.services.${sn}: ingress references undefined port '${p}'";

  enabled = lib.filterAttrs (_: s: s.enable) cfg.services;

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
  inherit isDomainName portOf;

  flat = {
    http = each (s: s.ingress.http);
    stream = each (s: s.ingress.stream);
    internal = each (s: s.ingress.internal);
  };
}
