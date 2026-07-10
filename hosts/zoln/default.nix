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

  local.hw.audio.enable = true;

  local.hw.splitKb = true;
}
