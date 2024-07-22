{ options, config, lib, configLib, outputs, ... }: {

  imports = [
    ./../../modules/home-manager
  ];

  options = {
    homePath = lib.mkOption {
      type = lib.types.path;
      default = "/home/nicolae";
    };
  };

  config = {
    programs.zsh.enable = true;

    home.username = "nicolae";

    home.sessionVariables = {
      EDITOR = "nvim";
    };

  };
}
