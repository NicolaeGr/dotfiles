{
  config,
  lib,
  configVars,
  ...
}:
let
  platform = config.local.platform;
in
{
  networking.extraHosts =
    "${configVars.net.lan.serverIp} ${lib.concatStringsSep " " (platform.domainsByHost.lumix or [ ])}\n"
    + lib.concatMapStrings (r: "${r.ip} ${r.fqdn}\n") platform.internalRecords;
}
