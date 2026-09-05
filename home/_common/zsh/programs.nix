{
  pkgs,
  lib,
  ...
}:
with lib;
{
  packages = with pkgs; [
    delta
    dust
    eza
    fd
    procs
    ripgrep
    sd
    doggo
    hyperfine
  ];

  rum-ext.programs.bat = {
    enable = true;
    extraPackages = with pkgs.bat-extras; [
      batgrep
      batwatch
      batman
    ];
    settings = {
      style = "numbers,changes,header";
    };
  };

  rum.programs.zoxide = {
    enable = true;
    flags = [ "--cmd cd" ];
    integrations.zsh.enable = true;
  };

  environment.sessionVariables = {
    LESS = "-RFX";
    LESSHISTFILE = "-";

    MAN_KEEP_FORMATTING = "1";

    DELTA_PAGER = "less";
  };

  rum.programs.zsh.initConfig = mkAfter ''
    alias cat="bat --paging=never"
    alias catp="bat --style=plain --paging=never"

    alias ls="eza"
    alias ll="eza -l"
    alias la="eza -la"
    alias lt="eza -T"
    alias tree="eza -T --icons=never"

    alias du="dust"
    alias ps="procs"
    alias dig="doggo"
    alias find="fd"
    alias diff="delta"

    alias man="batman"
    alias grepp="batgrep"
    alias watchp="batwatch"

    autoload -Uz colors && colors

    if command -v dircolors >/dev/null 2>&1; then
      eval "$(dircolors -b)"
    elif command -v gdircolors >/dev/null 2>&1; then
      eval "$(gdircolors -b)"
    fi

    zstyle ':completion:*' list-colors "''${(s.:.)LS_COLORS}"
    zstyle ':completion:*' menu select
  '';
}
