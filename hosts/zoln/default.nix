{
  inputs,
  config,
  configLib,
  pkgs,
  ...
}:
{
  imports = [
    inputs.aic8800.nixosModules.default

    ./hardware-configuration.nix
  ]
  ++ (map configLib.relativeToRoot [
    "hosts/_common/core"
    "hosts/_common/extra"
    "hosts/_common/users"
  ]);

  extra.gui.enable = true;
  extra.gui.hyprland.enable = true;

  extra.common.enable = true;
  extra.flatpak.enable = true;
  extra.common.devMode.enable = true;
  extra.hardware.audio.enable = true;
  extra.hardware.nvidia.enable = true;
  extra.hardware.backlight.enable = true;

  extra.gaming.enable = true;
  extra.gaming.jc.enable = true;
  extra.media.full.enable = true;

  semi-active-av.enable = true;

  hardware.aic8800.enable = true;
  boot.kernelModules = [ "btusb" ];
  boot.extraModprobeConfig = ''
    options btusb reset=1
  '';
  services.udev.extraRules = ''
    # AIC8800D80 Mode Switch: From MSC (a69c:5721) to WLAN (368b:8d81)
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="a69c", ATTR{idProduct}=="5721", RUN+="${pkgs.usb-modeswitch}/bin/usb_modeswitch -v a69c -p 5721 -K"

    # Enable udev rules for Vial-compatible devices (My Corne)
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{serial}=="*vial:f64c2b3c*", MODE="0660", GROUP="users", TAG+="uaccess", TAG+="udev-acl"
  '';

  environment.systemPackages = with pkgs; [
    calibre

    vial

    gimp
    avahi
    gitkraken

    unstable.android-studio
    unstable.gnome-builder
  ];

  boot.blacklistedKernelModules = [
    "amdgpu"
    "nouveau"
  ];

  boot.kernelPackages = pkgs.linuxPackages_zen;
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    open = true;
    nvidiaSettings = true;
    modesetting.enable = true;
    powerManagement.enable = true;

    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
}
