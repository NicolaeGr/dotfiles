{ configLib, lib, ... }: {
  imports = lib.flatten [
    (configLib.scanPaths ./.)
    (configLib.scanPaths ./hardware)
  ];

  config = {
    local.users.nicolae.enable = true;
  };
}
