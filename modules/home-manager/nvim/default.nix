{ inputs, pkgs, config, ... }: {

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  programs.neovim = {
    enable = true;
    vimAlias = true;
    vimdiffAlias = true;
    withNodeJs = true;

    plugins = with pkgs.vimPlugins; [
      lazy-nvim
    ];

    extraLuaConfig = ''
      require ('options')
      require ('keymaps')
      require ('commands')

      require ("lazy").setup ({
        spec = {
          { "LazyVim/LazyVim", import = "lazyvim.plugins" },
          { import = "plugins" },
        },
        performance = {
          reset_packpath = false,
          rtp = {
            reset = false,
          }
        },
        install = {
          -- Safeguard in case we forget to install a plugin with Nix
          missing = false,
        },
      })
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
