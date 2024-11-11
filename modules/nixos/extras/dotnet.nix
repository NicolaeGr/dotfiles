{ options, config, pkgs, lib, ... }: {
  options.extras.dotnet.enable = lib.mkEnableOption "dotnet";

  config = lib.mkIf config.extras.dotnet.enable {
    environment.sessionVariables = {
      DOTNET_ROOT = "${pkgs.dotnet-sdk_8}";
    };

    environment.systemPackages = with pkgs; [
      dotnetCorePackages.dotnet_8.sdk
      jetbrains.rider
    ];
  };
}
