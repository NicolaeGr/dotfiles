{ configLib, ... }: {
  imports = (configLib.scanPaths ./programs);
}
