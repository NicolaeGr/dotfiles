{
  lib,
  pkgs,
  configLib,
  ...
}:
{
  files = {
    "screenshot.png" = {
      target = ".config/hypr/icons/screenshot.png";
      source = ./screenshot.png;
    };
    "screenshot_utils.sh" = {
      target = ".config/hypr/scripts/screenshot_utils.sh";
      source = configLib.outOfStorePath ./screenshot_utils.sh;
      executable = true;
    };

    ".config/hypr/hyprland.lua".text = lib.mkAfter ''
      hl.bind("Print", hl.dsp.exec_cmd([[$HOME/.config/hypr/scripts/screenshot_utils.sh freeze]]))
      hl.bind("ALT + Print", hl.dsp.exec_cmd([[$HOME/.config/hypr/scripts/screenshot_utils.sh window]]))
      hl.bind(vars.mod .. " + Print", hl.dsp.exec_cmd([[$HOME/.config/hypr/scripts/screenshot_utils.sh full]]))
    '';
  };

  packages = with pkgs; [
    jq
    grim
    slurp
    wl-clipboard
    satty
    libnotify
    hyprpicker
  ];
}
