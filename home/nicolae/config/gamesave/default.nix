{ pkgs, ... }:
{
  services.ludusavi = {
    enable = true;
    package = pkgs.unstable.ludusavi;

    settings = {
      manifest.url = "https://raw.githubusercontent.com/mtkennerly/ludusavi-manifest/master/data/manifest.yaml";
      theme = "dark";

      backup.path = "~/.local/state/backups/ludusavi";
      restore.path = "~/.local/state/backups/ludusavi";

      roots = [
        {
          path = "~/.local/share/Steam";
          store = "steam";
        }
        {
          path = "~/.config/heroic";
          store = "heroic";
        }
      ];
    };
  };
}
