{ options, config, lib, pkgs, ... }: {
  options.profiles.gaming.apps.jc.enable = lib.mkEnableOption "Enable Steam";

  config = lib.mkIf config.profiles.gaming.apps.jc.enable {
    environment.systemPackages = with pkgs; [
      qbittorrent

      winetricks
      wineWowPackages.stable

      dwarfs
      fuse-overlayfs
      bubblewrap

      gst_all_1.gstreamer
      gst_all_1.gst-libav
      gst_all_1.gst-plugins-bad
      gst_all_1.gst-plugins-base
      gst_all_1.gst-plugins-good
      gst_all_1.gst-plugins-ugly
      gst_all_1.gst-vaapi
    ];

    # environment.variables = {
    #   __NV_PRIME_RENDER_OFFLOAD = "1";
    #   __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    #   __VK_LAYER_NV_optimus = "NVIDIA_only";
    #   VK_ICD_FILENAMES = "/usr/share/vulkan/icd.d/nvidia_icd.json";
    # };
  };
}
