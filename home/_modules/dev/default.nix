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
          (vscode.overrideAttrs (oldAttrs: {
            src = (
              builtins.fetchTarball {
                url = "https://update.code.visualstudio.com/latest/linux-x64/stable";
                sha256 = "sha256:070famap2mwf278zy4j8bxmzcrc1kcmcnyn08k2gyia54a2qpwmq";
              }
            );
            version = "latest";
          }))
        ];
      })
    ]
  );
}
