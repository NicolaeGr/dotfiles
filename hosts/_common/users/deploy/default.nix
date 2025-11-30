{
  pkgs,
  config,
  lib,
  configLib,
  ...
}:
# let
#   pubKeys = lib.filesystem.listFilesRecursive ./keys;
# in
{
  options = {
    users.deploy.enable = lib.mkEnableOption {
      default = false;
      description = "Enable The Deploy user configuration.";
    };
  };

  config = lib.mkIf config.users.deploy.enable {
    sops.secrets = {
      "passwords/deploy" = {
        neededForUsers = true;
      };
    };

    users.users.deploy = {
      isNormalUser = true;
      home = "/home/deploy";
      description = "Deploy";

      hashedPasswordFile = config.sops.secrets."passwords/deploy".path;
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

      # openssh.authorizedKeys.keys = lib.lists.forEach pubKeys (key: builtins.readFile key);
    };

    home-manager.users.deploy.imports = [
      {
        home = {
          username = "deploy";
          homeDirectory = "/home/deploy";
        };
      }
      (configLib.relativeToRoot "home/deploy/default.nix")
    ];
  };
}
