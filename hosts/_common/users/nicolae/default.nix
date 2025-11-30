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
    users.nicolae.enable = lib.mkEnableOption {
      default = false;
      description = "Enable Nicolae's user configuration.";
    };
  };

  config = lib.mkIf config.users.nicolae.enable {
    sops.secrets = {
      "passwords/nicolae" = {
        neededForUsers = true;
      };
    };

    users.users.nicolae = {
      isNormalUser = true;
      home = "/home/nicolae";
      description = "Nicolae";

      hashedPasswordFile = config.sops.secrets."passwords/nicolae".path;
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

    home-manager.users.nicolae.imports = [
      {
        home = {
          username = "nicolae";
          homeDirectory = "/home/nicolae";
        };
      }
      (configLib.relativeToRoot "home/nicolae/default.nix")
    ];
  };
}
