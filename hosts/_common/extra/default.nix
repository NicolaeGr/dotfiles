{
  config,
  configLib,
  lib,
  ...
}:
{
  imports = lib.flatten [ (configLib.scanPaths ./.) ];

  config = lib.mkMerge [
    {
      # Config
    }

    (lib.mkIf config.extra.gui.enable {
      # Config
      extra.hardware.audio.enable = true;
    })

    (lib.mkIf config.extra.gaming.enable {
      # Config
      extra.gaming.jc.enable = true;
    })
  ];
}
