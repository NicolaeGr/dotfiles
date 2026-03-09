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

  programs.neovim = {
    enable = true;
    vimAlias = true;
    defaultEditor = true;
    vimdiffAlias = true;
    withNodeJs = true;
    withPython3 = true;

    plugins = [
      pkgs.vimPlugins.lazy-nvim # All other plugins are managed by lazy-nvim
    ];

    extraPackages = [
      # Formatters
      pkgs.prettierd # Multi-language
      pkgs.shfmt # Shell
      pkgs.isort # Python
      pkgs.sqlfluff
      pkgs.stylua
      pkgs.copilot-language-server

      # LSP
      pkgs.lua-language-server # lua
      pkgs.nixd # nix
      pkgs.nil # nix
      pkgs.vtsls # typescript / javascript
      pkgs.nodePackages.vscode-json-languageserver

      # Tools
      pkgs.cmake
      pkgs.fswatch # File watcher utility, replacing libuv.fs_event for neovim 10.0
      pkgs.fzf
      pkgs.gcc
      pkgs.git
      pkgs.gnumake
      pkgs.nodejs
      pkgs.sqlite
      pkgs.tree-sitter
      pkgs.luarocks
      pkgs.luajit
      pkgs.hub
      pkgs.wget # for mason.nvim
      pkgs.pandoc # for devdocs.nvim
      pkgs.imagemagick
      pkgs.mermaid-cli
      pkgs.github-mcp-server
      pkgs.ghostscript

      # Languages
      pkgs.go
    ];

    extraLuaConfig = lib.mkIf (nvimLuaDir != null) ''
      -- Set FLAKE_ROOT as a Lua global variable
      vim.g.flake_root = "${if flakeRoot != "" then flakeRoot else "/etc/nixos/flake"}"

      require('keymaps')
      require('commands')

      require("lazy").setup({
        spec = {
          { import = "plugins" },
        },
        checker = {
          enabled = true
        },
      })

      require('options')
    '';
  };

  home.file.".config/nvim/lua" = lib.mkIf (nvimLuaDir != null) {
    source = config.lib.file.mkOutOfStoreSymlink nvimLuaDir;
  };
}
