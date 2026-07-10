{ lib, ... }:
{
  powerManagement.enable = true;
  services.power-profiles-daemon.enable = true;

  services.tlp.enable = lib.mkForce false;
  services.auto-cpufreq.enable = lib.mkForce false;
}
