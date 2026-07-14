{ configLib, ... }:
{
  files.".config/zsh/config.sh" = {
    source = ./zshrc;
  };

  rum.programs.zsh.initConfig = ''
    if [[ -f $XDG_CONFIG_HOME/zsh/config.sh ]]; then
      source $XDG_CONFIG_HOME/zsh/config.sh
    fi
  '';
}
