{
  pkgs,
  config,
  lib,
  ...
}:
{
  options.extra.common.devMode = {
    enable = lib.mkEnableOption "Enable development mode";
  };

  config = lib.mkIf config.extra.common.devMode.enable {
    environment.systemPackages =
      with pkgs;
      [
        # Security
        hashcat
        john
        ncrack
        android-tools

        tmux
      ]
      ++ lib.optionals config.extra.gui.enable [
        # Web
        insomnia
      ];

  };
}
