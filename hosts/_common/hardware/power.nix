{ lib, ... }:
{
  services.power-profiles-daemon.enable = true;

  powerManagement.enable = lib.mkForce false;
  services.tlp.enable = lib.mkForce false;
  services.auto-cpufreq.enable = lib.mkForce false;
}
