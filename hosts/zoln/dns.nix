{
  self,
  configVars,
  ...
}:
let
  serverIp = configVars.net.lan.serverIp;
  domains = self.nixosConfigurations.lumix.config.local.servedDomains;
in
{
  networking.extraHosts = ''
    ${serverIp} ${builtins.concatStringsSep " " domains}
  '';
}
