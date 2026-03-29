{
  inputs,
  configLib,
  pkgs,
  ...
}:
{
  imports = [
    inputs.hardware.nixosModules.lenovo-ideapad-15arh05
    ./hardware-configuration.nix

    ./fs.nix
    ./virt.nix
    ./wireguard.nix
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

  boot.kernelPackages = pkgs.unstable.linuxPackages_zen;
  environment.systemPackages = with pkgs; [
    calibre

    vial

    gimp
    avahi
    gitkraken

    unstable.android-studio
    unstable.gnome-builder
  ];

  services.udev.extraRules = ''
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{serial}=="*vial:f64c2b3c*", MODE="0660", GROUP="users", TAG+="uaccess", TAG+="udev-acl"
  '';

  services.postgresql = {
    enable = true;
    ensureDatabases = [
      "echobox"
    ];
    authentication = pkgs.lib.mkOverride 10 ''
      #type database  DBuser  auth-method
      local all       all     trust
      host  sameuser    all     127.0.0.1/32 scram-sha-256
      host  sameuser    all     ::1/128 scram-sha-256
    '';
    ensureUsers = [
      {
        name = "echobox";
        ensureDBOwnership = true;
        ensureClauses = {
          login = true;
        };
      }
    ];
  };
}
