{ config, ... }:
{
  sops.secrets."cloudflare_api_key" = { };

  services.cloudflare-dyndns = {
    enable = true;

    apiTokenFile = config.sops.secrets."cloudflare_api_key".path;

    frequency = "*:0/15";

    ipv4 = true;
    ipv6 = false;
    proxied = false;
    deleteMissing = false;
  };

  users.users.nginx.extraGroups = [ "acme" ];

  security.acme = {
    acceptTerms = true;
    defaults.email = "nicolaegr@proton.me";

    certs."electrolit.biz" = {
      domain = "*.electrolit.biz";
      group = "nginx";
      dnsProvider = "cloudflare";
      credentialFiles."CLOUDFLARE_DNS_API_TOKEN_FILE" = config.sops.secrets."cloudflare_api_key".path;
    };
  };
}
