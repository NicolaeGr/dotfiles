{ options, config, lib, pkgs, ... }: {

  options = {
    fonts.enable = lib.mkEnableOption {
      default = true;
      description = "Enable fonts";
    };
  };

  config = lib.mkIf config.fonts.enable {
    environment.systemPackages = with pkgs; [
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji

      font-awesome

      material-symbols

      gabarito-fonts

      (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
    ];
  };
}
