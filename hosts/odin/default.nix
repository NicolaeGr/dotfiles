{
  lib,
  self,
  configLib,
  ...
}:
{
  imports = lib.flatten [
    (configLib.scanPaths ./.)
    (self + "/hosts/_common")
  ];

  local.dev.enable = true;

  local.gui.hypr.enable = true;

  local.gaming.enable = true;
  local.gaming.jc.enable = true;
}
