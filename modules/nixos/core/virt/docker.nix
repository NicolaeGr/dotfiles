{ options, config, lib, pkgs, ... }: {
  options = {
    docker.enable = lib.mkEnableOption {
      description = "Enable Docker support.";
      default = false;
    };
  };

  config = lib.mkIf config.docker.enable {
    virtualisation.docker.enable = true;

    environment.systemPackages = with pkgs; [
      podman-desktop
    ];
  };
}
