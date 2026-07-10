{ lib, config, ... }: {
  options.local.gui.enable = lib.mkEnableOption "Enable GUI environment";

  config = lib.mkIf config.local.gui.enable {
  };
}
