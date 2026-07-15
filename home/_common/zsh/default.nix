{ configLib, ... }:
{
  files.".config/zsh/config.sh" = {
    source = configLib.outOfStorePath ./zshrc;
  };

  rum.programs.zsh.initConfig = ''
    if [[ -f $XDG_CONFIG_HOME/zsh/config.sh ]]; then
      source $XDG_CONFIG_HOME/zsh/config.sh
    fi
  '';
}
