{ inputs, outputs, config, lib, configLib, pkgs, ... }: {
  imports = [
    inputs.hardware.nixosModules.lenovo-ideapad-15arh05
    ./hardware-configuration.nix

    inputs.nix-flatpak.nixosModules.nix-flatpak

    (configLib.relativeToRoot "modules/nixos")
  ];

  devMode.enable = true;
  nvidia.enable = true;
  hyprland.enable = true;
  # gnome.enable = true;

  services.tlp.enable = lib.mkForce false;
  boot.kernelModules = [ "acpi_call" ];
  boot.extraModulePackages = with config.boot.kernelPackages; [ acpi_call ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelParams = [
    "amdgpu.backlight=0"
    "nvidia_drm.fbdev=1"
  ];

  environment.systemPackages = with pkgs; [
    discord
    telegram-desktop
  ];
}
