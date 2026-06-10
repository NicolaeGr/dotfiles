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
    programs.nosh.startAfter = [ "wayland-session@Hyprland.target" ];

    wayland.windowManager.hyprland.extraConfig =
      let
        nosh_cmd = "${inputs.nosh.packages.${pkgs.stdenv.hostPlatform.system}.default}/bin/nosh";
      in
      lib.mkAfter ''
        hl.bind("SUPER + X", hl.dsp.exec_cmd("${nosh_cmd} app-launcher"))

        hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("${nosh_cmd} volume-up"), { locked = true, repeating = true })
        hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("${nosh_cmd} volume-down"), { locked = true, repeating = true })
        hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("${nosh_cmd} brightness-up"), { locked = true, repeating = true })
        hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("${nosh_cmd} brightness-down"), { locked = true, repeating = true })
      '';
  };
}
