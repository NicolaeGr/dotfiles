{ config, lib, ... }:
{

  options = {
    extra.hyprland.waybar.enable = lib.mkEnableOption {
      default = false;
      description = "Enable the Waybar status bar.";
    };
  };

  config = lib.mkIf config.extra.hyprland.waybar.enable {
    programs.waybar = {
      enable = true;
      systemd.enable = true;
      systemd.target = "hyprland-session.target";

      settings = [
        {
          layer = "top";
          position = "top";
          height = 33;
          # width = 1350;
          margin = "6, 20, 2, 20";

          modules-left = [
            "hyprland/workspaces"
            "cpu"
            "custom/separator"
            "memory"
            "custom/separator"
            "network"
            "custom/recorder"
            "custom/audiorec"
          ];

          modules-center = [
            "clock"
            "mpd"
          ];

          modules-right = [
            "tray"
            "custom/separator"
            "idle_inhibitor"
            "custom/separator"
            "backlight"
            "custom/separator"
            "battery"
            "custom/separator"
            "pulseaudio"
          ];

          "custom/wmname" = {
            format = "";
            tooltip = false;
          };

          "hyprland/workspaces" = {
            format = "{icon}";
            format-icons = {
              "1" = "1";
              "2" = "2";
              "3" = "3";
              "4" = "4";
              "5" = "5";
              "6" = "6";
              "7" = "7";
              "8" = "8";
              "9" = "9";
              "10" = "0";
              "urgent" = "";
              "focused" = "";
              "default" = "";
            };
          };

          "custom/language" = {
            exec = "swaymsg --type get_inputs | grep \"xkb_active_layout_name\" | sed -u '1!d; s/^.*xkb_active_layout_name\": \"//; s/ (US)//; s/\",//' && swaymsg --type subscribe --monitor '[\"input\"]' | sed -u 's/^.*xkb_active_layout_name\": \"//; s/\",.*$//; s/ (US)//'";
          };

          "custom/separator" = {
            format = "|";
            interval = "once";
            tooltip = false;
          };

          idle_inhibitor = {
            format = "{icon}";
            format-icons = {
              activated = "";
              deactivated = "";
            };
          };

          tray = {
            icon-size = 20;
            spacing = 6;
          };

          clock = {
            interval = 1;
            locale = "C";
            format = " {:%I:%M %p}";
            format-alt = " {:%a,%b %d}";
          };

          cpu = {
            format = "&#8239; {usage}%";
            tooltip = false;
            on-click = "kitty -e 'btop'";
          };

          memory = {
            interval = 30;
            format = "  {used:0.2f} GB";
            max-length = 10;
            tooltip = false;
            warning = 70;
            critical = 90;
          };

          temperature = {
            critical-threshold = 80;
            format = "{icon}&#8239;{temperatureC} °C";
            format-icons = [
              ""
              ""
              ""
            ];
          };

          backlight = {
            format = "{icon}&#8239;{percent}%";
            format-icons = [
              "💡"
              "💡"
            ];
            on-scroll-down = "light - U 10";
            on-scroll-up = "light - A 10";
          };

          battery = {
            states = {
              warning = 30;
              critical = 15;
            };
            format = "{icon}&#8239;  {capacity}%";
            format-charging = "&#8239;{capacity}%";
            format-plugged = "&#8239; {capacity}%";
            format-alt = "{icon}  {time}";
            format-icons = [
              ""
              ""
              ""
              ""
              ""
            ];
          };

          network = {
            format-wifi = "&#8239;  ({signalStrength}%)";
            format-ethernet = "&#8239;{ifname}";
            format-linked = "&#8239; {ifname} (No IP)";
            format-disconnected = "✈&#8239; No Net";
            format-alt = "{ifname}: {ipaddr}/{cidr}";
            tooltip-format = "{essid}: {ipaddr}";
          };

          pulseaudio = {
            format = "{icon} {volume}% {format_source}";
            format-bluetooth = "{icon}  {volume}% {format_source}";
            format-bluetooth-muted = " {format_source}";
            format-muted = "  {format_source}";
            format-source = " {volume}%";
            format-source-muted = "";
            format-icons = {
              headphone = "";
              hands-free = "";
              headset = "🎧";
              phone = "";
              portable = "";
              car = "";
              default = [
                ""
                ""
                ""
              ];
            };
            on-click = "pavucontrol";
          };

          mpd = {
            format = "{stateIcon} {artist} - {title}";
            format-disconnected = "🎶";
            format-stopped = "♪";
            interval = 10;
            consume-icons = {
              on = " ";
            };
            random-icons = {
              off = ''<span color="#f53c3c"></span> '';
              on = " ";
            };
            repeat-icons = {
              on = " ";
            };
            single-icons = {
              on = "1 ";
            };
            state-icons = {
              paused = "";
              playing = "";
            };
            tooltip-format = "MPD (connected)";
            tooltip-format-disconnected = "MPD (disconnected)";
            max-length = 45;
          };

          "custom/recorder" = {
            format = " Rec";
            format-disabled = " Off-air";
            return-type = "json";
            interval = 1;
            exec = "echo '{\"class\": \"recording\"}'";
            exec-if = "pgrep wf-recorder";
          };

          "custom/audiorec" = {
            format = "♬ Rec";
            format-disabled = "♬ Off-air";
            return-type = "json";
            interval = 1;
            exec = "echo '{\"class\": \"audio recording\"}'";
            exec-if = "pgrep ffmpeg";
          };
        }
      ];

      style = builtins.readFile ./styles.css;
    };
  };
}
