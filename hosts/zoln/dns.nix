{
  self,
  ...
}:
let
  serverIp = "192.168.100.10";

  domains = self.nixosConfigurations.lumix.config.local.servedDomains;

  address = map (domain: "/${domain}/${serverIp}") domains;
in
{
  services.dnsmasq = {
    enable = true;

    settings = {
      cache-size = 1000;
      server = [ serverIp ];
      inherit address;
    };
  };

  networking.nameservers = [ "127.0.0.1" ];
}
