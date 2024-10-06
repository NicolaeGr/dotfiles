{ options, config, lib, pkgs, ... }: {
  options.profiles.gaming.apps.jc.enable = lib.mkEnableOption "Enable Steam";

  config = lib.mkIf options.profiles.gaming.apps.jc.enable {
    environment.systemPackages = with pkgs; [
      qbittorrent
      dwarfs
      wine-staging
      fuse-overlayfs

      gst-libav
      gst-plugins-bad1
      gst-plugins-base1
      gst-plugins-good1
      gst-plugins-ugly1
      gstreamer-vaapi
    ];

    environment.variables = {
      __NV_PRIME_RENDER_OFFLOAD = "1";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      __VK_LAYER_NV_optimus = "NVIDIA_only";
      VK_ICD_FILENAMES = "/usr/share/vulkan/icd.d/nvidia_icd.json";
    };
  };
}
