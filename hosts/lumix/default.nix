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

  local.users.deploy.enable = true;
  local.users.victor.enable = true;
  local.users.adrian.enable = true;

  local.dev.enable = true;

  services.nginx.enable = true;
  services.croc.enable = true;
}
