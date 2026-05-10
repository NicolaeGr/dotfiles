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

    domains = [ "electrolit.biz" ];
    frequency = "*:0/5"; # every 5 mins

    ipv4 = true;
    ipv6 = false;
    proxied = false;
    deleteMissing = false;
  };

  security.acme = {
    acceptTerms = true;
    defaults.email = "nicolaegr@proton.me";
    certs."electrolit.biz" = {
      extraDomainNames = [ "*.electrolit.biz" ];
      dnsProvider = "cloudflare";
      credentialsFile = config.sops.templates."cloudflare-acme-env".path;
    };
  };
}
