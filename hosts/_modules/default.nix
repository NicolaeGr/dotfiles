{ configLib, lib, ... }: {
  imports = lib.flatten [
    (configLib.scanPaths ./.)
    (configLib.scanPaths ./hardware)
  ];
}
