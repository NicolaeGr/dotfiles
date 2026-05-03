{
  config,
  pkgs,
  lib,
  ...
}:
let
  containerLib = import ./_util.nix { inherit pkgs lib; };
  baseDir = "/storage/jellyfin";
in
{
  networking.interfaces.br0.ipv4.addresses = [
    {
      address = "10.200.0.1";
      prefixLength = 24;
    }
  ];

  networking.firewall.extraForwardRules = ''
    # 1. Allow established connections
    ct state established,related accept

    # Allow LAN and Wireguard to talk to the services
    iifname "br0" oifname "br0" accept
    iifname "wg0" oifname "br0" accept

    # BLOCK the outside world from hitting your service subnet
    iifname "eth-wan" oifname "br0" ip daddr 10.200.2.0/24 reject
  '';

  containers.bazarr = containerLib.mkServiceContainer {
    name = "bazarr";
    ip = "10.200.2.10";
    ports = [ 6767 ];
    mounts = {
      "/storage/media" = {
        hostPath = "/storage/media";
        isReadOnly = false;
      };
    };
    serviceConfig = ./bazarr.nix;
  };

  containers.navidrome = containerLib.mkServiceContainer {
    name = "navidrome";
    ip = "10.200.1.10";
    ports = [ 4533 ];
    mounts = {
      "${baseDir}/navidrome" = {
        hostPath = "${baseDir}/navidrome";
        isReadOnly = false;
      };
      "/storage/media/music" = {
        hostPath = "/storage/media/music";
        isReadOnly = true;
      };
    };
    serviceConfig = ./navidrome.nix;
  };
}
