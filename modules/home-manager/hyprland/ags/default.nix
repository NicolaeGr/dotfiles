{ inputs, config, lib, pkgs }: {
  imports = [ inputs.ags.homeManagerModules.default ];

  options.hyprland.ags.enable = lib.mkEnableOption {
    default = false;
    description = "Enable the AGS environment";
  };

  config = lib.mkIf config.hyprland.ags.enable {
    programs.ags = {
      enable = true;

      configDir = ./conf;

      extraPackages = with pkgs; [
        gtksourceview
        webkitgtk
        accountsservice
      ];
    };
  };
}
