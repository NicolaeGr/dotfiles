{
  lib,
  pkgs,
  config,
  inputs,
  configLib,
  ...
}:
let
  dbusVars = [
    # "DISPLAY"
    # "HYPRLAND_INSTANCE_SIGNATURE"
    # "WAYLAND_DISPLAY"
    # "XDG_CURRENT_DESKTOP"
    # "XDG_SESSION_TYPE"
    "--all"
  ];
in
{
  imports = (configLib.scanPaths ./.);

  options.local.gui.hypr.enable = lib.mkEnableOption "Enable Hyprland";

  config = lib.mkIf config.local.gui.hypr.enable {
    local.gui.enable = true;

    packages = with pkgs; [
      kitty

      inputs.nosh.packages.${pkgs.stdenv.hostPlatform.system}.default
      awww
    ];

    systemd.targets."hyprland-session" = {
      description = "Hyprland session";
      bindsTo = [ "graphical-session.target" ];
      wants = [ "graphical-session-pre.target" ];
      after = [ "graphical-session-pre.target" ];
    };

    files = {
      ".config/hypr/hyprland.lua" = {
        text = ''
          hl.on("hyprland.start", function()
              os.execute ("dbus-update-activation-environment --systemd ${lib.concatStringsSep " " dbusVars}")
              os.execute ("systemctl --user start hyprland-session.target")
          end)

          hl.on("hyprland.shutdown", function()
              os.execute("systemctl --user stop hyprland-session.target && sleep 0.1")
          end)
          require ("modules")
        '';
      };
      ".config/hypr/modules" = {
        source = ./modules;
      };
      ".config/hypr/backgrounds" = {
        source = ./bgs;
      };
    };
  };
}
