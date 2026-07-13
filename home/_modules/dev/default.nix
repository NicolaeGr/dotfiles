{
  lib,
  pkgs,
  config,
  ...
}:
{
  options.local.dev.enable = lib.mkEnableOption "Enable development environment";

  config = lib.mkIf config.local.dev.enable (
    lib.mkMerge [
      {
        packages = with pkgs; [
          # Editors
          vim
          neovim

          # Terminals
          tmux

          # Tools
          uget
          glow
          fd
          ripgrep
          bat
          fzf
          eza
          tldr
          tokei
          ngrok
          gnumake
          prettier

          # Languages
          gcc
          rustup
          nodejs
          python3
          go

          # Package Managers
          pnpm
          yarn

          # Networking
          nmap
        ];
      }

      (lib.mkIf config.local.gui.enable {
        packages = with pkgs; [
          insomnia
        ];
      })
    ]
  );
}
