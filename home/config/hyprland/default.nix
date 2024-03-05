{
  imports = [ ./waybar ./hyprlock ./rofi ];

  home.file = {
    "hypridle.conf" = {
      target = ".config/hypr/hypridle.conf";
      source = ./hypridle.conf;
    };
  };

  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      exec-once = [ "waybar && firefox" ];

      monitor = ",highres,auto,1";

      "$mod" = "SUPER";
      "$terminal" = "kitty";
      "$menu" = "rofi -show drun";
      "$fileManager" = "dolphin";

      env = [
        "XCURSOR_SIZE,24"
        "QT_QPA_PLATFORMTHEME,qt5ct"
      ];

      input = {
        "kb_layout" = "us";

        "natural_scroll" = "no";
        touchpad = {
          "natural_scroll" = "yes";
        };
      };

      general = {
        "gaps_in" = 5;
        "gaps_out" = 20;
        "border_size" = 2;

        "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
        "col.inactive_border" = "rgba(595959aa)";

        "layout" = "dwindle";

        "allow_tearing" = false;
      };


      decoration = {
        rounding = 10;

        blur = {
          enabled = true;
          size = 3;
          passes = 1;
        };

        drop_shadow = "yes";
        shadow_range = 4;
        shadow_render_power = 3;
        "col.shadow" = "rgba(1a1a1aee)";
      };

      animations = {
        enabled = true;

        bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";

        animation = [
          "windows, 1, 7, myBezier"
          "windowsOut, 1, 7, default, popin 80%"

          "border, 1, 10, default"
          "borderangle, 1, 8, default"

          "fade, 1, 7, default"

          "workspaces, 1, 6, default"
        ];
      };

      dwindle = {
        pseudotile = "yes";

        # preserve_split = "yes";
      };


      gestures = {
        workspace_swipe = true;
        workspace_swipe_fingers = 3;
      };

      bind = [
        "$mod, B, exec, firefox"
        "$mod, T, exec, $terminal"
        "$mod, Q, killactive,"
        "$mod, L, exec, hyprlock"
        "$mod+Shift, L, exec, hyprlock"
        "$mod, F, exec, $fileManager"
        "$mod, V, togglefloating,"
        "$mod, X, exec, $menu"
        "$mod, P, pseudo,"
        "$mod, J, togglesplit,"

        "$mod, left, movefocus, l"
        "$mod, right, movefocus, r"
        "$mod, up, movefocus, u"
        "$mod, down, movefocus, d"

        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod, 5, workspace, 5"
        "$mod, 6, workspace, 6"
        "$mod, 7, workspace, 7"

        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"
        "$mod SHIFT, 4, movetoworkspace, 4"
        "$mod SHIFT, 5, movetoworkspace, 5"
        "$mod SHIFT, 6, movetoworkspace, 6"
        "$mod SHIFT, 7, movetoworkspace, 7"

        "$mod, S, togglespecialworkspace, magic"
        "$mod SHIFT, S, movetoworkspace, special:magic"

        "$mod, mouse_down, workspace, e+1"
        "$mod, mouse_up, workspace, e-1"
      ];

      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
        "$mod SHIFT, mouse:273, resizewindow 1"
      ];
      
      bindl = [
        ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        "$mod+Shift, L, exec, sleep 0.1 && systemctl suspend"
      ];

      bindel = [
        ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ", XF86MonBrightnessUp, exec, light -A 10"
        ", XF86MonBrightnessDown, exec, light -U 10"

        ", XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
        ", Print, exec, hyprshot -m region -o Pictures/Screenshots"
        "Alt, Print, exec, hyprshot -m window -o Pictures/Screenshots"
        "$mod, Print, exec, hyprshot -m output -o Pictures/Screenshots"
      ];
    };
  };
}
