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
          python3
          go

          # Networking
          nmap
        ];
      }
      {
        packages = with pkgs; [
          nodejs
          pnpm
        ];

        environment.sessionVariables = {
          PNPM_HOME = "$HOME/.local/share/pnpm";

          NPM_CONFIG_USERCONFIG = "$HOME/.config/npm/npmrc";
          NPM_CONFIG_CACHE = "$HOME/.cache/npm";
          NPM_CONFIG_DEVDIR = "$HOME/.cache/node-gyp";

          COREPACK_HOME = "$HOME/.cache/corepack";
          NODE_REPL_HISTORY = "$HOME/.local/state/node_repl_history";
        };

        # TODO: Need to integrate this as well

        # environment.interactiveShellInit = ''
        #   export PATH="$PNPM_HOME:$PATH"
        # '';

        # cat <<EOF > ~/.config/npm/npmrc
        # prefix=${HOME}/.local/share/pnpm
        # cache=${HOME}/.cache/npm
        # EOF
      }
      (lib.mkIf config.local.gui.enable {
        packages = with pkgs; [
          stable.bruno
          stable.vscode

          zed-editor
        ];
      })
    ]
  );
}
