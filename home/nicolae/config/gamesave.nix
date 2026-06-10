{
  pkgs,
  lib,
  hostName,
  ...
}:
{
  config = lib.mkIf (hostName == "odin" || hostName == "zoln") {
    home.packages = [
      pkgs.unstable.ludusavi
      (pkgs.writeShellScriptBin "ludusavi-restore-all" ''
        ${pkgs.ludusavi}/bin/ludusavi --config $HOME/.config/ludusavi restore --force
      '')
    ];

    xdg.configFile."ludusavi/config.yaml".source =
      let
        yamlFormatter = pkgs.formats.yaml { };
      in
      yamlFormatter.generate "config.yaml" {
        manifest.url = "https://raw.githubusercontent.com/mtkennerly/ludusavi-manifest/master/data/manifest.yaml";
        theme = "dark";

        backup = {
          path = "~/.local/state/backups/ludusavi";
          ignoredGames = [
            "Brawlhalla"
            "Counter-Strike 2"
            "Dead by Daylight"
            "Forza Horizon 5"
            "Hollow Knight: Silksong"
          ];
          filter = {
            excludeStoreScreenshots = true;
            cloud = {
              exclude = true;
              epic = true;
              gog = true;
              origin = true;
              steam = true;
              uplay = true;
            };
          };
          retention = {
            full = 3;
            differential = 0;
          };
        };
        restore = {
          path = "~/.local/state/backups/ludusavi";
        };

        roots = [
          {
            path = "~/.local/share/Steam";
            store = "steam";
          }
          {
            path = "~/.config/heroic";
            store = "heroic";
          }
          {
            path = "~/.local/share/lutris";
            store = "lutris";
          }
        ];
      };
  };
}
