{
  lib,
  self,
  config,
  ...
}:
{
  options.local.users.nicolae.enable = lib.mkEnableOption "Enable nicolae user";

  config = {
    hjem = {
      enable = true;
      clobberByDefault = true;

      extraModules = [
        (self + "/home/_common")
      ];
    };
  }
  // lib.mkIf config.local.users.nicolae.enable {
    users.users.nicolae = {
      isNormalUser = true;
      home = "/home/nicolae";
      extraGroups = [
        "wheel"
        "docker"
      ];
      initialPassword = "nicolae";
    };

    hjem.users.nicolae = {
      enable = true;
      user = "nicolae";
      directory = "/home/nicolae";

      imports = [ (self + "/home/nicolae") ];
    };
  };
}
