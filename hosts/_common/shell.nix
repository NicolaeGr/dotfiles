{ pkgs, ... }: {
  environment.shells = [ pkgs.zsh ];
  users.defaultUserShell = pkgs.zsh;

  environment.systemPackages = [ pkgs.fzf ];

  programs.zsh = {
    enable = true;

    enableCompletion = true;
    enableBashCompletion = true;

    enableLsColors = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;

    histFile = "\${XDG_STATE_HOME:-$HOME/.local/state}/zsh/history";
    histSize = 10000;
    shellInit = ''
      export ZDOTDIR="''${XDG_CONFIG_HOME:-$HOME/.config}/zsh"

      export ZSH_NEWUSER_INSTALL="$ZDOTDIR"
    '';

    setOptions = [
      "EXTENDED_HISTORY"
      "HIST_IGNORE_ALL_DUPS"
      "HIST_IGNORE_DUPS"
      "HIST_IGNORE_SPACE"
      "SHARE_HISTORY"

      "AUTO_CD"
    ];

    interactiveShellInit = ''
      export ZSH_CACHE_DIR="''${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
      export ZSH_COMPDUMP_DIR="''${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump-$ZSH_VERSION"
      export HISTTIMEFORMAT="[%F %T] "

      mkdir -p "''${HISTFILE%/*}"
    '';
  };

  hjem.extraModules = [
    {
      rum.programs.zsh = {
        enable = true;
      };

      files = {
        ".zshenv" = {
          target = ".config/zsh/.zshenv";
        };
        ".zshrc" = {
          target = ".config/zsh/.zshrc";
        };
      };
    }
  ];
}
