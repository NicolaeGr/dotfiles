{
  lib,
  self,
  outputs,
  configLib,
  ...
}:
{
  imports = lib.flatten [
    (self + "/hosts/_modules")
    (configLib.scanPaths ./.)
    (builtins.attrValues outputs.nixosModules)
  ];

  system.stateVersion = "26.05";

  boot.initrd.systemd.enable = true;
  boot.loader = {
    systemd-boot.enable = true;
    systemd-boot.configurationLimit = lib.mkDefault 10;

    timeout = 3;
    efi.canTouchEfiVariables = true;
  };

  i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";
  time.timeZone = lib.mkDefault "Europe/Chisinau";
  console.keyMap = "us";

  security.sudo.extraConfig = ''
    Defaults lecture = never
    Defaults pwfeedback
    Defaults env_keep+=SSH_AUTH_SOCK
  '';
}
