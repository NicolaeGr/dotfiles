{ inputs, pkgs, config, ... }: {

  # nvim plugins overlay
  nixpkgs.overlays = [
    (final: prev: {
      vimPlugins = prev.vimPlugins // {
        fine-cmdline-nvim = prev.vimUtils.buildVimPlugin {
          name = "fine-cmdline.nvim";
          src = inputs.fine-cmdline-nvim;
        };
        cust_lualine-nvim = prev.vimUtils.buildVimPlugin {
          name = "lualine.nvim";
          src = inputs.lualine-nvim;
        };
      };
    })
  ];

  programs.neovim =
    let
      toLua = str: "lua << EOF\n${str}\nEOF\n";
      toLuaFile = file: "lua << EOF\n${builtins.readFile file}\nEOF\n";
    in
    {
      enable = true;

      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;

      extraPackages = with pkgs; [
        wl-clipboard

        lua-language-server
        rnix-lsp
      ];

      plugins = with pkgs.vimPlugins; [
        # Git integration
        vim-fugitive
        vim-rhubarb
        {
          plugin = gitsigns-nvim;
          config = toLua "require('gitsigns').setup()";
        }

        # Auto tabstop and shiftwidth detection
        vim-sleuth

        # Discord presence
        presence-nvim

        # Better Command Line
        nui-nvim
        fine-cmdline-nvim

        # Show pending keyybinds
        which-key-nvim

        # Status Line
        {
          plugin = lualine-nvim;
          config = toLua "require('lualine').setup { options = {icons_enabled = false, theme = 'auto', component_separators = { left = '|', right = '|'}, section_separators = { left = '', right = ''} } }";
        }
        {
          plugin = indent-blankline-nvim-lua;
          config = toLua "require('ibl').setup { indent = { char = '┊' }, exclude = { buftypes = { 'terminal' } } }";
        }

        # 'gc' to comment visual regions/lines
        comment-nvim
      ];

      extraLuaConfig = ''
        ${builtins.readFile ./lua/options.lua}
        ${builtins.readFile ./lua/commands.lua}
        ${builtins.readFile ./lua/keymaps.lua}
      '';
    };
}
