{
  self,
  configVars,
  ...
}:
let
  serverIp = configVars.net.lan.serverIp;

  domains = self.nixosConfigurations.lumix.config.local.servedDomains;

  address = map (domain: "/${domain}/${serverIp}") domains;
in
{
  services.dnsmasq = {
    enable = true;

    settings = {
      cache-size = 1000;
      server = [
        "1.1.1.1"
        "8.8.8.8"
      ];
      inherit address;
    };
  };
}
