{
  lib,
  pkgs,
  config,
  configLib,
  ...
}:
{
  imports = (configLib.scanPaths ./.);

  options.local.dev.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = "Enable development environment";
  };

  config = lib.mkIf config.local.dev.enable (
    lib.mkMerge [
      {
        rum.programs.direnv = {
          enable = true;
          integrations.zsh.enable = true;
          integrations.nix-direnv.enable = true;
        };

        rum.programs.helix = {
          enable = true;
        };

        environment.sessionVariables.EDITOR = lib.mkForce "hx";
        environment.sessionVariables.VISUAL = lib.mkForce "hx";

        packages = with pkgs; [
          # Terminals
          tmux

          # Tools
          uget
          glow
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
          stable.bruno
          stable.vscode

          zed-editor-fhs
        ];
      })
    ]
  );
}
