{ inputs, outputs, system, pkgs, options, config, lib, configLib, ifGroupExists, ... }: {
  options = {
    users.nicolae.enable = lib.mkEnableOption {
      default = false;
      description = "Enable Nicolae's user configuration.";
    };
  };

  config = lib.mkIf config.users.nicolae.enable {
    users.users.nicolae = {
      isNormalUser = true;
      home = "/home/nicolae";
      description = "Primary Account";

      extraGroups = [
        "wheel"
      ] ++ configLib.ifUserGroupExists [
        "networkmanager"
        "audio"
        "video"
        "render"
        "input"
        "storage"
        "users"
        "power"
        "libvirt"
        "docker"
      ]
        config;
    };

    home-manager.users.nicolae = {
      imports = [
        (configLib.relativeToRoot "home/nicolae")
      ];
      home.stateVersion = "23.11";
    };
  };
}
