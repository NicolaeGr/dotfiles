{ pkgs, config, ... }:
{
  programs.zsh = {
    enable = true;
    dotDir = "${config.xdg.configHome}/zsh";

    initContent = builtins.readFile ./.zshrc;

    autocd = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    history = {
      expireDuplicatesFirst = true;
      ignoreDups = true;
      ignoreAllDups = true;
      ignoreSpace = true;
      extended = true;
      size = 10000;
      share = true;
      path = "$XDG_STATE_HOME/zsh/history";
    };

    localVariables = {
      ZSH_CACHE_DIR = "$XDG_CACHE_HOME/zsh";
      ZSH_COMPDUMP_DIR = "$XDG_CACHE_HOME/zsh/zcompdump-$ZSH_VERSION";
      HISTTIMEFORMAT = "[%F %T] ";
    };

    shellAliases = {
      cat = "bat";
      diff = "batdiff";
      rg = "batgrep";
      man = "batman";

      l = "eza -lah";
      la = "eza -lah";
      ll = "eza -lh";
      ls = "eza";
      lsa = "eza -lah";

      e = "nvim";
      vi = "nvim";
      vim = "nvim";

      nfc = "nix flake check";
      ne = "nix instantiate --eval";
      nb = "nix build";
      ns = "nix shell";
    };

    plugins = [
      {
        name = "vi-mode";
        src = pkgs.zsh-vi-mode;
        file = "share/zsh-vi-mode/zsh-vi-mode.plugin.zsh";
      }
      {
        name = "zsh-term-title";
        src = "${pkgs.zsh-term-title}/share/zsh/zsh-term-title/";
      }
      {
        name = "cd-gitroot";
        src = "${pkgs.cd-gitroot}/share/zsh/cd-gitroot";
      }
    ];
  };
}
