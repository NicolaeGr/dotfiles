{ options, config, lib, pkgs ... }: {
  options = {
    users.guest.enable = lib.mkEnableOption {
      default = false;
      description = "Enable Nicolae's user configuration.";
    };
  };

  config = lib.mkIf config.users.guest.enable { };
}
