{ self, configLib, ... }:
{
  imports = [
    (self + "/home/_modules")
  ]
  ++ (configLib.scanPaths ./.);
}
