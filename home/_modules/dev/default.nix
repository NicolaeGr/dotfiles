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
          fzf
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
          (vscode.overrideAttrs (oldAttrs: {
            src = (
              builtins.fetchTarball {
                url = "https://update.code.visualstudio.com/latest/linux-x64/stable";
                sha256 = "sha256:10y1bq1nzak22k0cpv323pi4swqs3jzjmkd0393c2jaz4w1h8p5f";
              }
            );
            version = "latest";
            buildInputs = oldAttrs.buildInputs ++ [
              pkgs.krb5
              pkgs.libsoup_3
              pkgs.webkitgtk_4_1
            ];
          }))
        ];
      })
    ]
  );
}
