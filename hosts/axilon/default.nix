{ inputs, outputs, config, lib, configLib, pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix

    (configLib.relativeToRoot "modules/nixos")
  ];

  devMode.enable = true;
  hyprland.enable = true;

  services.tlp.enable = lib.mkForce false;
  boot.kernelModules = [ "acpi_call" ];
  boot.extraModulePackages = with config.boot.kernelPackages; [ acpi_call ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  environment.systemPackages = with pkgs; [
    discord
    telegram-desktop
  ];

  users.nicolae.enable = true;
}
