{ options, config, lib, pkgs, ... }: {
  imports = [
    ./dotnet.nix
  ];

  options.extras.enable = lib.mkEnableOption "Enable extra packages";

  config = lib.mkIf config.extras.enable {
    environment.systemPackages = with pkgs;  [
      libreoffice

      discord
      telegram-desktop
    ];
  };
}
