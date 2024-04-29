{
  environment.pathsToLink = [ "/share/zsh" ];

  programs.zsh.enable = true;

  environment.sessionVariables = rec {
    ZDOTDIR = "$HOME/.config/zsh";
  };
}