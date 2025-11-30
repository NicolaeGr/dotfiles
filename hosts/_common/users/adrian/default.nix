{
  pkgs,
  config,
  lib,
  configLib,
  ...
}:
let
  pubKeys = lib.filesystem.listFilesRecursive ./keys;
in
{
  options = {
    users.adrian.enable = lib.mkEnableOption {
      default = false;
      description = "Enable Adrian's user configuration.";
    };
  };

  config = lib.mkIf config.users.adrian.enable {
    sops.secrets = {
      "passwords/adrian" = {
        neededForUsers = true;
      };
    };

    users.users.adrian = {
      isNormalUser = true;
      home = "/home/adrian";
      description = "Adrian";

      hashedPasswordFile = config.sops.secrets."passwords/adrian".path;
      packages = [ pkgs.home-manager ];

      extraGroups = [
        "wheel"
      ]
      ++ configLib.ifUserGroupExists [
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
        "adbusers"
        "vboxusers"
        "sambashare"
      ] config;

      openssh.authorizedKeys.keys = lib.lists.forEach pubKeys (key: builtins.readFile key);
    };

    home-manager.users.adrian.imports = [
      {
        home = {
          username = "adrian";
          homeDirectory = "/home/adrian";
        };
      }
      (configLib.relativeToRoot "home/adrian/default.nix")
    ];
  };
}
