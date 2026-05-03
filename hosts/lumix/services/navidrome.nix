{ ... }:
{
  services.navidrome = {
    enable = true;
    openFirewall = true;
    user = "deploy";
    group = "users";
    settings = {
      Address = "0.0.0.0";
      Port = 4533;
      MusicFolder = "/storage/media/music";
      DataFolder = "/storage/jellyfin/navidrome";
    };
  };
}
