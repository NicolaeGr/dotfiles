{ pkgs, lib, ... }:
{
  imports = [
    ./_util.nix

    # System Pub
    ./jellyfin.nix

    # System Priv
    ./webui
    ./qbit.nix

    # Containers Pub
    ./komga.nix
    ./navidrome.nix

    # Containers Priv
    ./arr.nix
    ./sea.nix
  ];

  config = {
    services.cloudflare-dyndns.domains = [
      "*.electrolit.biz"
    ];

    services.nginx.virtualHosts."_" = {
      default = true;
      locations."/".return = "403";

      addSSL = true;
      useACMEHost = "electrolit.biz";
    };

    services.fail2ban = {
      enable = true;

      jails = {
        nginx-http-auth = ''
          enabled  = true
          filter   = nginx-http-auth
          logpath  = /var/log/nginx/error.log
          maxretry = 3
          bantime  = 3600
        '';

        nginx-badbots = ''
          enabled = true
          filter  = nginx-badbots
          logpath = /var/log/nginx/access.log
          maxretry = 2
          bantime  = 86400
        '';
      };
    };
  };
}
