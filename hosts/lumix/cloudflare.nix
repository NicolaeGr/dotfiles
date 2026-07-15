{ config, ... }:
{
  sops.secrets."cloudflare_api_key" = { };

  sops.templates."cloudflare-acme-env" = {
    content = "CLOUDFLARE_DNS_API_TOKEN=${config.sops.placeholder.cloudflare_api_key}";
    owner = "acme";
  };

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
      extraDomainNames = [ "*.electrolit.biz" ];
      dnsProvider = "cloudflare";
      credentialFiles = {
        "CLOUDFLARE_DNS_API_TOKEN_FILE" = config.sops.templates."cloudflare-acme-env".path;
      };
    };
  };
}
