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
    environment.systemPackages = with pkgs; [
      qbittorrent

      dwarfs
      fuse-overlayfs
      bubblewrap

      # gst_all_1.gstreamer
      # gst_all_1.gst-libav
      # gst_all_1.gst-plugins-bad
      # gst_all_1.gst-plugins-base
      # gst_all_1.gst-plugins-good
      # gst_all_1.gst-plugins-ugly
      # gst_all_1.gst-vaapi
    ];
  };
}
