{ options, config, lib, pkgs, ... }: {

  options = {
    fonts.enable = lib.mkEnableOption {
      default = false;
      description = "Enable fonts";
    };
  };

  config = lib.mkIf config.fonts.enable {
    fonts.fontDir.enable = true;

    fonts.packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji

      font-awesome

      fira-code
      fira-code-symbols

      material-symbols

      gabarito-fonts

      (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
    ];
  };
}
