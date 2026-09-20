{
  lib,
  pkgs,
  config,
  inputs,
  ...
}:
with lib;
let
  cfg = config.local.gui.hypr;
in
{
  imports = [
    inputs.nosh.nixosModules.nosh
  ];

  options.local.gui.hypr.enable = mkEnableOption "Enable Hyprland";

  config = mkIf cfg.enable {
    local.gui.enable = true;
    hjem.extraModules = [ { local.gui.hypr.enable = true; } ];

    services.logind.settings.Login = {
      HandlePowerKey = "suspend-then-hibernate";
    };

    programs.hyprland = {
      enable = true;
      withUWSM = true;
    };

    environment.systemPackages = [
      pkgs.brightnessctl
    ];

    services.upower.enable = true;

    services.hypridle.enable = true;

    security.pam.services.hyprlock = { };
  };
}
