{
  inputs,
  pkgs,
  config,
  lib,
  ...
}:
let
  flakeRoot = builtins.getEnv "FLAKE_ROOT";
  storePath = builtins.toString ./.;
  relPath = builtins.head (builtins.match ".*/[^/]+-source/(.*)" storePath);

  liveCheckout = if flakeRoot != "" then flakeRoot + "/" + relPath else null;
  nvimLuaDir =
    if liveCheckout != null && builtins.pathExists (liveCheckout + "/lua") then
      liveCheckout + "/lua"
    else
      (builtins.trace "⚠️ Lua folder missing at ${if liveCheckout != null then liveCheckout else "unknown"}/lua; Neovim will use default config" null);
in
{

  programs.neovim =
    let
      nvimPackDir = pkgs.vimUtils.packDir config.programs.neovim.finalPackage.passthru.packpathDirs;
    in
    {
      enable = true;
      vimAlias = true;
      vimdiffAlias = true;

      plugins =
        let
          plugins = pkgs.unstable.vimPlugins;
        in
        with plugins;
        [
          lazy-nvim
          lazydev-nvim

          # LSP
          nvim-lspconfig

          # Formatting
          conform-nvim

          # Editor
          which-key-nvim
          trouble-nvim

          # UI
          nui-nvim
          fine-cmdline-nvim
          sleuth
          presence-nvim
          snacks-nvim
          bufferline-nvim
          lualine-nvim

          # Treesitter and language support
          nvim-treesitter-context
          nvim-ts-autotag
          nvim-treesitter-textobjects
          nvim-treesitter.withAllGrammars

          # Comments
          nvim-ts-context-commentstring
          todo-comments-nvim
          ts-comments-nvim

          # Search functionality
          plenary-nvim
          popup-nvim
          telescope-nvim
          telescope-fzf-native-nvim

          # Theme
          catppuccin-nvim
          mini-icons

          #Cmp
          nvim-cmp
          cmp-nvim-lsp
          cmp-buffer
          cmp-path
          nvim-snippets
          friendly-snippets

        ];

      extraPackages = with pkgs; [
        gcc # needed for nvim-treesitter

        # LazyVim defaults
        stylua
        shfmt

        # LSP servers
        nixd # Nix
      ];

      extraLuaConfig = lib.mkIf (nvimLuaDir != null) ''
        -- Set FLAKE_ROOT as a Lua global variable
        vim.g.flake_root = "${if flakeRoot != "" then flakeRoot else "/etc/nixos/flake"}"

        require('options')
        require('keymaps')
        require('commands')

        require("lazy").setup({
          performance = {
            reset_packpath = false,
            rtp = {
                reset = false,
              }
            },
          dev = {
             path = "${nvimPackDir}/pack/myNeovimPackages/start",
             patterns = {""},
          },
          install = {
            -- Safeguard in case we forget to install a plugin with Nix
            missing = false,
          },
          spec = {
            { import = "plugins" },
          },
        })
      '';
    };

  home.packages = with pkgs; [
    wl-clipboard
    lua-language-server
  ];

  home.file.".config/nvim/lua" = lib.mkIf (nvimLuaDir != null) {
    source = config.lib.file.mkOutOfStoreSymlink nvimLuaDir;
  };
}
