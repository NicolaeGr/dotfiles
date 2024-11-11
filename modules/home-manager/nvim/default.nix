{ inputs, pkgs, config, ... }: {

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  programs.neovim = {
    enable = true;
    vimAlias = true;
    vimdiffAlias = true;
    withNodeJs = true;

    extraLuaConfig = ''
      require('options')
      require('keymaps')
      require('commands')
      require('config.lazy')
    '';
  };

  home.packages = with pkgs; [
    wl-clipboard
    lua-language-server
  ];

  xdg.configFile."nvim/lua" = {
    recursive = true;
    source = config.lib.file.mkOutOfStoreSymlink ./lua;
  };
}
