{ lib, config, options, pkgs, ... }: {

  options = {
    xdg.enable = lib.mkEnableOption {
      default = true;
      description = "Enable xdg";
    };
  };

  config = lib.mkIf config.xdg.enable {
    environment.systemPackages = with pkgs; [
      xdg-utils
      xdg-user-dirs
    ];

    xdg = {
      mime = {
        enable = true;
        defaultApplications = {
          "text/plain" = [ "codium.desktop" ];
          "inode/directory" = [ "org.gnome.Nautilus.desktop" ];
        };
      };
    };
  };
}
