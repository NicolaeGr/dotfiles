{ ... }:
let
  baseDir = "/storage/jellyfin";

  mkArrVhost = port: {
    extraConfig = ''
      proxy_pass http://localhost:${toString port};
    '';
  };
in
{
  networking.firewall.allowedTCPPorts = [ 80 ];

  services.nginx = {
    enable = true;
    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    virtualHosts = {
      "radarr.electrolit.biz" = mkArrVhost 7878;
      "sonarr.electrolit.biz" = mkArrVhost 8989;
      "bazarr.electrolit.biz" = mkArrVhost 6767;
      "lidarr.electrolit.biz" = mkArrVhost 8686;
      "prowlarr.electrolit.biz" = mkArrVhost 9696;
    };
  };

  services.radarr = {
    enable = true;
    openFirewall = true;

    dataDir = "${baseDir}/radarr";

    user = "deploy";
    group = "users";
  };

  services.sonarr = {
    enable = true;
    openFirewall = true;

    dataDir = "${baseDir}/sonarr";

    user = "deploy";
    group = "users";
  };

  services.bazarr = {
    enable = true;
    openFirewall = true;
    user = "deploy";
    group = "users";
  };

  services.lidarr = {
    enable = true;
    openFirewall = true;

    dataDir = "${baseDir}/lidarr";

    user = "deploy";
    group = "users";
  };

  services.prowlarr = {
    enable = true;
    openFirewall = true;
  };
}
