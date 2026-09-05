{
  pkgs,
  config,
  lib,
  ...
}:
{
  options = {
    local.gaming.jc.enable = lib.mkEnableOption "Enable gaming support";
  };

  config = lib.mkIf config.local.gaming.jc.enable {
    programs.fuse.userAllowOther = true;
    boot.kernelModules = [ "fuse" ];

    environment.sessionVariables = {
      DOTNET_ROOT = "${pkgs.dotnet-runtime_8}/share/dotnet";
    };

    environment.systemPackages = with pkgs; [
      qbittorrent

      stable.dwarfs
      fuse-overlayfs
      bubblewrap
      psmisc
      zenity
      aria2
      zstd
      p7zip
      cabextract

      dotnet-sdk_8
      dotnet-runtime_8
    ];
  };
}
