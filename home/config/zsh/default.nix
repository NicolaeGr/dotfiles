{
  environment.pathsToLink = [ "/share/zsh" ];

  programs.zsh = {
    enable = true;

    enableCompletion = true;
    enableAutosuggestions = true;
    syntaxHighlighting = {
      enable = true;
    };
  };
}
