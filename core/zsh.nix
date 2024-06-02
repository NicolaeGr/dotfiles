{ config, options, lib, ... }: {
  options = {
    zsh.enable = lib.mkEnableOption {
      default = false;
      description = "Enable zsh";
    };
  };

  config = lib.mkIf config.zsh.enable {
    environment.pathsToLink = [ "/share/zsh" ];

    programs.zsh.enable = true;

    environment.sessionVariables = rec {
      ZDOTDIR = "$HOME/.config/zsh";
    };
  };
}
