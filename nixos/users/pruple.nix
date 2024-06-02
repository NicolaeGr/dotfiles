{ inputs, outputs, system, pkgs, options, config, lib, configLib, ifGroupExists, ... }: {
  options = {
    users.pruple.enable = lib.mkEnableOption {
      default = false;
      description = "Enable Pruple's user configuration.";
    };
  };

  config = lib.mkIf config.users.pruple.enable {
    users.users.pruple = {
      isNormalUser = true;
      home = "/home/pruple";
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

    home-manager.users.pruple = {
      imports = [
        (configLib.relativeToRoot "home/pruple")
      ];
      home.stateVersion = "23.11";
    };
  };
}
