{ pkgs, ... }: {
  programs.zsh = {
    enable = true;
    dotDir = ".config/zsh";

    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;


    history = {
      expireDuplicatesFirst = true;
      ignoreDups = true;
      ignoreAllDups = true;
      ignoreSpace = true;
      extended = true;
      path = "$XDG_STATE_HOME/zsh/history";
    };

    # envExtra = '''';

    shellAliases = {
      ll = "ls -l";
      la = "ls -la";
      l = "ls -CF";
    };

    localVariables = {
      ZSH_CACHE_DIR = "$XDG_CACHE_HOME/zsh";
      ZSH_COMPDUMP_DIR = "$XDG_CACHE_HOME/zsh/zcompdump-$ZSH_VERSION";
      HISTTIMEFORMAT = "[%F %T] ";
    };

    initExtra = builtins.readFile ./.zshrc;

    plugins = [
      {
        name = "vi-mode";
        src = pkgs.zsh-vi-mode;
        file = "share/zsh-vi-mode/zsh-vi-mode.plugin.zsh";
      }
    ];
  };
}
