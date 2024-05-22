{ inputs, config, lib, pkgs, ... }: {
  imports =
    [
      ./hardware-configuration.nix

      inputs.home-manager.nixosModules.home-manager
    ];

  services.tlp.enable = lib.mkForce false;
  boot.kernelModules = [ "acpi_call" ];
  boot.extraModulePackages = with config.boot.kernelPackages; [ acpi_call ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelParams = [ "amdgpu.backlight=0" ];

  networking.hostName = "zion";
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Chisinau";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";
}
