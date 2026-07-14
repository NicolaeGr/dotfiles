{
  lib,
  self,
  outputs,
  configLib,
  ...
}:
{
  imports = lib.flatten [
    (self + "/home/_modules")
    (configLib.scanPaths ./.)
    (builtins.attrValues outputs.hjemModules)
  ];
}
