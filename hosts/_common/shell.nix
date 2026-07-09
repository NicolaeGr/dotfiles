{ pkgs, ... }: {
  environment.shells = [ pkgs.zsh ];
  users.defaultUserShell = pkgs.zsh;

  environment.systemPackages = [ pkgs.fzf ];

  programs.zsh = {
    enable = true;
    enableCompletion = true;
  };

  hjem.extraModules = [
    {
      rum.programs.zsh = {
        enable = true;
      };
    }
  ];
}
