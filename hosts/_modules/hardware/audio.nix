{
  lib,
  pkgs,
  config,
  ...
}:
{
  options.local.hw.audio.enable = lib.mkEnableOption "Enable audio support";

  config = lib.mkIf config.local.hw.audio.enable {
    security.rtkit.enable = true;

    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;

      wireplumber.enable = true;

      extraConfig.pipewire = {
        "99-input-denoising" = {
          "context.modules" = [
            {
              name = "libpipewire-module-echo-cancel";
              args = {
                aec.args = {
                  "webrtc.noise_suppression" = true;
                  "webrtc.gain_control" = true;
                };
              };
            }
          ];
        };
      };
    };

    hardware.firmware = [ pkgs.sof-firmware ];

    environment.systemPackages = with pkgs; [
      pavucontrol
      qpwgraph
      pwvucontrol
      easyeffects
    ];
  };
}
