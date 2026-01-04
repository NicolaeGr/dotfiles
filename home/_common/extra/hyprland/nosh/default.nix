{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    inputs.nosh.homeManagerModules.nosh
  ];

  options = {
    extra.hyprland.nosh.enable = lib.mkEnableOption {
      default = false;
      description = "Enable the nosh integration for Hyprland";
    };
  };

  config = lib.mkIf config.extra.hyprland.nosh.enable {
    programs.nosh.enable = true;
    programs.nosh.startAfter = [ "hyprland-session.target" ];

    wayland.windowManager.hyprland.settings.bindel =
      let
        nosh_cmd = "${inputs.nosh.packages.${pkgs.system}.default}/bin/nosh";
      in
      [
        ", XF86AudioRaiseVolume, exec, ${nosh_cmd} volume-up"
        ", XF86AudioLowerVolume, exec, ${nosh_cmd} volume-down"
        ", XF86MonBrightnessUp, exec, ${nosh_cmd} brightness-up"
        ", XF86MonBrightnessDown, exec, ${nosh_cmd} brightness-down"
      ];
  };
}
