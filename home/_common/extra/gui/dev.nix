{
  config,
  lib,
  pkgs,
  ...
}:
{

  options.extra.dev.enable = lib.mkEnableOption {
    default = true;
    description = "Enable development tools";
  };

  config = lib.mkIf (config.extra.dev.enable && config.extra.gui.enable) {
    home.packages = with pkgs; [
      unstable.chromium
      unstable.epiphany
      unstable.jetbrains.idea-oss
      unstable.gitkraken
    ];

    programs.vscode.enable = true;
    programs.vscode.package = pkgs.vscode.overrideAttrs (oldAttrs: {
      src = (
        builtins.fetchTarball {
          url = "https://update.code.visualstudio.com/1.117.0/linux-x64/stable";
          sha256 = "sha256:0nxr92dm6h732rpqpxsbn56r0yw2ckva9d06p6q65k2mz6w0f3jl";
        }
      );
      version = "1.116.0";
      buildInputs = oldAttrs.buildInputs ++ [
        pkgs.krb5
        pkgs.libsoup_3
        pkgs.webkitgtk_4_1
      ];
    });
  };
}
