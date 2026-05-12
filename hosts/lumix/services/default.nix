{ pkgs, lib, ... }:
{
  imports = [
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
  };
}
