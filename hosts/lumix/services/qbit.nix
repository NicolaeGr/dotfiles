{ lib, pkgs, ... }:
let
  containerLib = import ./_util.nix { inherit pkgs lib; };
  baseDir = "/storage/jellyfin";
in
{
  services.qbittorrent = {
    user = "deploy";
    group = "users";

    profileDir = "${baseDir}/qbittorrent";
    webuiPort = 8020;
    openFirewall = true;
    serverConfig = {
      LegalNotice.Accepted = true;
      Preferences = {
        General.Locale = "en";
        WebUI.CSRFProtection = false;
        WebUI.HostHeaderValidation = true;
        WebUI.Username = "user";
        WebUI.Password_PBKDF2 = "@ByteArray(6/PxK1oTs3CuJ92zB2gzxg==:Efg0yQ8y9Jp3M1Y/IEA8G/DYWge3QwnHWhrwW/5tZbu5nVHuLQfJY7Bb2EwjOfJc9a044juSiKNgjZby+1wR3g==)";
      };
    };
  };

  services.nginx.virtualHosts."bit.electrolit.biz" = containerLib.withPrivateAccess {
    locations."/" = {
      proxyPass = "http://127.0.0.1:8020";
    };
  };
}
