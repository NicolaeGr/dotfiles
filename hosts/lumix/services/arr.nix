{ ... }:
let
  baseDir = "/storage/jellyfin";
in
{
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
