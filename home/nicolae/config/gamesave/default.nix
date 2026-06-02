{ pkgs, ... }:
{
  services.ludusavi = {
    enable = true;
    package = pkgs.unstable.ludusavi;

    settings = {
      manifest.url = "https://raw.githubusercontent.com/mtkennerly/ludusavi-manifest/master/data/manifest.yaml";
      theme = "dark";

      backup.path = "$XDG_STATE_HOME/backups/ludusavi";
      restore.path = "$XDG_STATE_HOME/backups/ludusavi";

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
