{
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
          "custom/wmname"
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

        # "sway/workspaces" = {
        #   disable-scroll = true;
        #   all-outputs = true;
        #   format = "{icon}";
        #   format-icons = {
        #     "1" = "";
        #     "2" = "";
        #     "3" = "";
        #     "4" = "";
        #     "5" = "";
        #     "6" = "";
        #     "7" = "";
        #     "8" = "";
        #     "9" = "";
        #     "urgent" = "";
        #     "focused" = "";
        #     "default" = "";
        #   };
        # };

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
          format-icons = [ "" "" "" ];
        };

        backlight = {
          format = "{icon}&#8239;{percent}%";
          format-icons = [ "💡" "💡" ];
          on-scroll-down = "brightnessctl -c backlight set 1%-";
          on-scroll-up = "brightnessctl -c backlight set +1%";
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
          format-icons = [ "" "" "" "" "" ];
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
          format-bluetooth = "{icon} {volume}% {format_source}";
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
            default = [ "" "" "" ];
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
            off = "<span color=\"#f53c3c\"></span> ";
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

    style = ''
      @define-color critical #ff0000; /* critical color */
      @define-color warning #f3f809;  /* warning color */
      @define-color fgcolor #ffffff;  /* foreground color */
      @define-color bgcolor #303030;  /* background color */
      @define-color bgcolor #222436;  /* background color */
      @define-color alert   #df3320;

      @define-color accent1 #ff7a93;
      @define-color accent2 #b9f27c;
      @define-color accent3 #ff9e64;
      @define-color accent4 #bb9af7;
      @define-color accent5 #7da6ff;
      @define-color accent6 #0db9d7;

      * {
          /* `otf-font-awesome` is required to be installed for icons */
          border: none;
          font-family: "JetBrainsMono";
          /* Recommended font sizes: 720p: ~14px, 1080p: ~18px */
          font-size: 14px;
      }

      window#waybar {
          background-color: rgba(34, 36, 54, 0.6);
          border-bottom: 0px solid rgba(100, 114, 125, 0.5);
          color: #ffffff;
          transition-property: background-color;
          transition-duration: .5s;
          border-radius: 6px;
      }

      window#waybar.hidden {
          opacity: 0.2;
      }

      #workspaces button {
          padding: 0px;
          margin: 4px 0 6px 0;
          background-color: transparent;
          color: #ffffff;
          min-width: 36px;
      }

      #workspaces button.active {
          padding: 0 0 0 0;
          margin: 4px 0 6px 0;
          background-color: #ddddff;
          color: #303030;
          min-width: 36px;
      }

      #workspaces button:hover {
          background: rgba(0, 0, 0, 0.2);
          color: #ffffff;
      }

      #workspaces button.focused {
          background-color: #bbccdd;
          color: #323232;
      }

      #workspaces button.urgent {
          color: red;
      }

      #mode {
          background-color: #64727D;
          border-bottom: 1px solid #ffffff;
      }

      #clock,
      #battery,
      #cpu,
      #memory,
      #temperature,
      #backlight,
      #network,
      #pulseaudio,
      #custom-media,
      #tray,
      #mode,
      #idle_inhibitor,
      #custom-power,
      #custom-pacman,
      #language {
          padding: 0px 3px;
          margin: 4px 3px 5px 3px;
          color: @fgcolor;
          background-color:transparent;
      }

      #window,
      #workspaces {
          margin: 0 4px;
      }

      /* If workspaces is the leftmost module, omit left margin */
      .modules-left > widget:first-child > #workspaces {
          margin-left: 0;
      }

      /* If workspaces is the rightmost module, omit right margin */
      .modules-right > widget:last-child > #workspaces {
          margin-right: 0;
      }

      #clock {
          color: #90ee90;
      }

      #battery {
          color: @accent5;
      }

      @keyframes blink {
          to {
              background-color: #ffffff;
              color: #333333;
          }
      }

      #battery.critical:not(.charging) {
          background-color: @critical;
          color: @white;
      }

      label:focus {
          background-color: #000000;
      }

      #cpu {
          color: @accent1;
      }

      #memory {
          color: #86e2d5;
      }

      #backlight {
          color: @accent2;
      }

      #network {
          color: @accent3;
      }

      #network.disconnected {
          color: @alert;
      }

      #pulseaudio {
          color: @accent4;
      }

      #pulseaudio.muted {
          color: #a0a0a0;
      }

      #custom-power {
          color: @accent6;
      }

      #custom-waylandvsxorg {
          color: @accent5;
      }

      #custom-pacman {
          color: @accent2;
      }

      #custom-media {
          background-color: #66cc99;
          color: #2a5c45;
          min-width: 100px;
      }

      #custom-media.custom-spotify {
          background-color: #66cc99;
      }

      #custom-media.custom-vlc {
          background-color: #ffa000;
      }

      #temperature {
          color: @accent6;
      }

      #temperature.critical {
          background-color: @critical;
      }

      #tray {

      }

      #idle_inhibitor {
          background-color: #343434;
          border-radius: 4px;
      }

      #mpd {
          color: #d1e231;
      }

      #custom-language {
          color: @accent5;
          min-width: 16px;
      }

      #custom-separator {
          color: #606060;
          margin: 0 1px;
          padding-bottom: 5px;
      }

      #custom-wmname {
          min-width: 36px;
          font-size: 15px;
      }

      #custom-recorder,
      #custom-audiorec {
          color: #c71585;
      }
    '';
  };
}
