{ inputs, pkgs, config, ... }: {
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

      ];

      extraLuaConfig = ''
        ${builtins.readFile ./init.vim}
       '';
    };
}
