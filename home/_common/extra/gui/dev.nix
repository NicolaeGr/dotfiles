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
          url = "https://update.code.visualstudio.com/1.118.0/linux-x64/stable";
          sha256 = "sha256:1gilgcyb09zsl14jmnk869z68ma9h19l06wcgcg28fg5bs5dpz63";
        }
      );
      version = "1.118.0";
      buildInputs = oldAttrs.buildInputs ++ [
        pkgs.krb5
        pkgs.libsoup_3
        pkgs.webkitgtk_4_1
      ];
    });
  };
}
