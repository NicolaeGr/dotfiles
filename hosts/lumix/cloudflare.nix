{ config, ... }:
{
  sops.secrets."cloudflare_api_key" = { };

  users.users.nginx.extraGroups = [ "acme" ];

  security.acme = {
    acceptTerms = true;
    defaults.email = "nicolaegr@proton.me";

    certs."electrolit.biz" = {
      domain = "*.electrolit.biz";
      group = "nginx";
      dnsProvider = "cloudflare";
      credentialFiles."CLOUDFLARE_DNS_API_TOKEN_FILE" = config.sops.secrets."cloudflare_api_key".path;

      # lego gives the DNS-01 propagation check a fixed 2 minutes, while
      # Cloudflare serves TXT records with a 120s TTL. A cached answer at
      # 1.1.1.1 can outlive the check, so verify against the authoritative
      # nameservers instead of the recursive resolvers.
      extraLegoFlags = [ "--dns.propagation.disable-rns" ];
    };
  };
}
