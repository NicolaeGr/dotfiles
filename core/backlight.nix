{ pkgs, config, options, lib, ... }: {

  options = {
    backlight.enable = lib.mkEnableOption {
      default = false;
      description = "Enable backlight control";
    };
  };

  config = lib.mkIf config.backlight.enable {
    environment.systemPackages = with pkgs; [
      xorg.xbacklight
    ];

    programs.light.enable = true;
    security.sudo.extraRules = [
      {
        groups = [ "wheel" ];
        commands = [
          {
            options = [ "NOPASSWD" ];
            command = "${pkgs.light}/bin/light";
          }
        ];
      }
    ];
  };
}
