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

  local.gui.hypr.enable = true;
}
