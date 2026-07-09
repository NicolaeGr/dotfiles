{ configLib, lib, ... }: {
  imports = lib.flatten [ (configLib.scanPaths ./.) ];

  config = {
    local.users.nicolae.enable = true;
  };
}
