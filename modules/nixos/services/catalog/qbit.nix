{
  lib,
  platformOwns,
  ...
}:
let
  baseDir = "/storage/jellyfin";
in
{
  config = lib.mkMerge [
    {
      local.platform.services.qbit = {
        host = "lumix";
        ports.http = 8020;

        ingress.http."bit.electrolit.biz" = {
          port = "http";
        };
      };
    }

    (lib.mkIf (platformOwns "qbit") {
      services.qbittorrent = {
        enable = true;

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
    })
  ];
}
