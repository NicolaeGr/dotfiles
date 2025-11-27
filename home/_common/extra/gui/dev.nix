{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
{

  options.extra.dev.enable = lib.mkEnableOption {
    default = true;
    description = "Enable development tools";
  };

  config = lib.mkIf (config.extra.dev.enable && config.extra.gui.enable) {
    home.packages = with pkgs; [
      unstable.vscode
      unstable.chromium
      unstable.epiphany
      unstable.jetbrains.idea-community
      unstable.gitkraken
    ];
  };
}
