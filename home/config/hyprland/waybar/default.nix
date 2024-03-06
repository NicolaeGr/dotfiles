{
  programs.waybar = {
    enable = true;

    settings = {
      layer = "bottom";
      position = "bottom";
      height = 30;
      margin-top = -10;
      margin-bottom = 0;
      margin-right = 100;
      margin-left = 100;

      # Modules
      "modules-left" = [ "clock" ];
      "modules-center" = [ "sway/workspaces" ];
      "modules-right" = [ "pulseaudio" "custom/d" "mpd" ];

      # Modules configuration
      "custom/d" = {
        "format" = "|";
        "tooltip" = false;
      };
      "sway/workspaces" = {
        "disable-scroll" = true;
        "all-outputs" = true;
        "format" = "{icon}";
        "format-icons" = {
          "1a" = "";
          "2a" = "";
          # "2b" = "";
          "3a" = "";
          "4a" = "";
          "5a" = "";
          "0b" = "";
          "1b" = "";
          "2b" = "";
          "3b" = "";
          "4b" = "";
          "5b" = "";
          "6b" = "";
          "7b" = "";
          "8b" = "";
          "9b" = "";
          "urgent" = "";
          "default" = "";
        };
      };
      "mpd" = {
        "format" = "<span>{stateIcon} </span> ";
        "format-disconnected" = "<span color=\"#bf616a\"> </span> ";
        "format-stopped" = "<span color=\"#bf616a\"> </span> ";
        "tooltip" = false;
        "interval" = 1;
        "state-icons" = {
          "paused" = "<span color=\"#d08770\"></span>";
          "playing" = "<span color=\"#a3be8c\"></span>";
        };
      };
      "clock" = {
        "interval" = 1;
        "tooltip-format" = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
        "format" = "<span color=\"#88c0d0\"></span> {:%Y-%m-%d;; %H:%M:%S}";
      };
      "pulseaudio" = {
        "format" = "{volume}% <span color=\"#88c0d0\">{icon} </span>{format_source}";
        "format-muted" = "<span color=\"#d08770\">婢 </span>{format_source}";
        "format-source" = "<span color=\"#88c0d0\"> </span>";
        "format-source-muted" = "<span color=\"#d08770\"> </span>";
        "format-icons" = {
          "headset" = "";
          "default" = [ "" "" ];
        };
        "on-click" = "amixer set Master toggle && amixer set Capture toggle";
        "on-click-right" = "amixer set Capture toggle";
        "on-click-middle" = "alacritty --class floating -e pulsemixer";
      };
    };

    style = ''
          * {
          border= 0;
          font-family= Cozette;
          font-size= 12px;
          min-height= 0;
      }

      window#waybar {
          background= transparent;
          color= #eceff4;
      }

      window#waybar:first-child > box {
          margin-top= 11px;
          padding= 8px 4px 4px 4px;
          border-radius= 20px 20px 0px 0px;
          background-color= #2e3440;
          border= 2px solid #88c0d0;
          border-bottom= 0;
      }

      #workspaces button {
          padding= 0 5px;
          background= transparent;
          color= #4c566a;
      }

      #workspaces button:hover {
          box-shadow= inherit;
          text-shadow= inherit;
          color= #d8dee9;
      }

      #workspaces button.focused {
          color= #88c0d0;
      }

      #custom-d; #clock; #pulseaudio {
          padding= 0 7px;
          margin= 2px 0px;
      }

      #mpd {
          margin= 0;
      }

      #pulseaudio {
        margin-right= -7px;
      }

      #custom-d {
          color= #4c566a;
      }
    '';
  };
}
