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
    users.victor.enable = lib.mkEnableOption {
      default = false;
      description = "Enable Victor's user configuration.";
    };
  };

  config = lib.mkIf config.users.victor.enable {
    sops.secrets = {
      "passwords/victor" = {
        neededForUsers = true;
      };
    };

    users.users.victor = {
      isNormalUser = true;
      home = "/home/victor";
      description = "Victor";

      hashedPasswordFile = config.sops.secrets."passwords/victor".path;
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

    home-manager.users.victor.imports = [
      {
        home = {
          username = "victor";
          homeDirectory = "/home/victor";
        };
      }
      (configLib.relativeToRoot "home/victor/default.nix")
    ];
  };
}
