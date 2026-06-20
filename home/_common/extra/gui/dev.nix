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

    programs.vscode.enable = lib.mkIf config.extra.gui.enable true;
    programs.vscode.package = pkgs.unstable.vscode.overrideAttrs (oldAttrs: {
      src = (
        builtins.fetchTarball {
          url = "https://update.code.visualstudio.com/latest/linux-x64/stable";
          sha256 = "sha256:0pzid4gh2niqc3j5d30cgy1jzarlbc7pyq4lpjh7436mbm45j9f5";
        }
      );
      version = "latest";
      buildInputs = oldAttrs.buildInputs ++ [
        pkgs.krb5
        pkgs.libsoup_3
        pkgs.webkitgtk_4_1
      ];
    });
  };
}
