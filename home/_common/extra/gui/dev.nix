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
    programs.vscode.package = pkgs.unstable.vscode.overrideAttrs (oldAttrs: {
      src = (
        builtins.fetchTarball {
          url = "https://update.code.visualstudio.com/1.123.0/linux-x64/stable";
          sha256 = "sha256:0k8g7c1a386p9fji5k4mzb4an4mkfycx03ki9b573xi0a94c8xm3";
        }
      );
      version = "1.123.0";
      buildInputs = oldAttrs.buildInputs ++ [
        pkgs.krb5
        pkgs.libsoup_3
        pkgs.webkitgtk_4_1
      ];
    });
  };
}
