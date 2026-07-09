{
  lib,
  self,
  configLib,
  ...
}:
{
  imports = [
    (self + "/hosts/_modules")
  ]
  ++ (configLib.scanPaths ./.);

  system.stateVersion = "26.05";
  hardware.enableRedistributableFirmware = true;

  boot.initrd.systemd.enable = true;
  boot.loader = {
    systemd-boot.enable = true;
    systemd-boot.configurationLimit = lib.mkDefault 10;

    timeout = 3;
    efi.canTouchEfiVariables = true;
  };

  services.fwupd.enable = true;

  i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";
  time.timeZone = lib.mkDefault "Europe/Chisinau";
  console.keyMap = "us";

  security.sudo.extraConfig = ''
    Defaults lecture = never
    Defaults pwfeedback
    Defaults env_keep+=SSH_AUTH_SOCK
  '';
}
