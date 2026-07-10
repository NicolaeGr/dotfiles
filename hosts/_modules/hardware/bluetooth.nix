{
  lib,
  pkgs,
  config,
  ...
}:
{
  options.local.hw.bluetooth.enable = lib.mkEnableOption "Enable bluetooth support";

  config =
    lib.mkIf config.local.hw.bluetooth.enable {
      hardware.bluetooth = {
        enable = true;
        powerOnBoot = true;

        settings = {
          General = {
            Experimental = true;
            KernelExperimental = true;

            FastConnectable = true;
            ReconnectAttempts = 7;
            ReconnectIntervals = "1,2,3,5,10,15,30";

            MultiProfile = "multiple";
            ControllerMode = "dual";
          };

          LE = {
            MinConnectionInterval = 7;
            MaxConnectionInterval = 9;
            ConnectionLatency = 0;
            ConnectionTimeout = 4000;
          };
        };
      };

      environment.systemPackages = with pkgs; [
        bluez-tools
      ];

      services.pipewire.wireplumber.extraConfig = {
        "11-bluetooth-policy" = {
          "wireplumber.settings" = {
            "bluetooth.autoswitch-to-headset-profile" = true;
          };
        };
        "12-bluetooth-codecs" = {
          "monitor.bluez.properties" = {
            "bluez5.enable-sbc-xq" = true;
            "bluez5.enable-msbc" = true;
            "bluez5.enable-hw-volume" = true;
            "bluez5.codecs.ldac.abr" = true;

            "override.bluez5.codecs" = [
              "ldac"
              "aptx_hd"
              "aptx"
              "aac"
              "sbc_xq"
              "sbc"
              "msbc"
              "cvsd"
            ];
          };
        };
      };
    }
    // lib.mkIf (config.local.gui.enable && config.local.hw.bluetooth.enable) {
      services.blueman.enable = true;
    };
}
