{
  inputs,
  hostName,
  config,
  lib,
  pkgs,
  ...
}:
{

  imports = [
    ./screenshots
    ./hyprlock
    ./hypridle
    ./rofi
    ./swww
    ./nosh
  ];

  options = {
    extra.hyprland.enable = lib.mkEnableOption {
      default = true;
      description = "Enable Hyprland compositor";
    };
  };

  config = lib.mkIf config.extra.hyprland.enable {
    extra.hyprland.hypridle.enable = true;
    extra.hyprland.hyprlock.enable = true;
    extra.hyprland.rofi.enable = true;
    extra.hyprland.swww.enable = true;
    extra.hyprland.nosh.enable = true;

    home.packages = with pkgs; [
      libnotify
    ];

    wayland.windowManager.hyprland = {
      enable = true;

      systemd = {
        enable = true;
        variables = [ "--all" ];
      };

      settings = {
        exec-once = [
          "${pkgs.dbus}/bin/dbus-update-activation-environment --systemd --all"
          ''${pkgs.bash}/bin/bash -c 'eval "$(${pkgs.gnome-keyring}/bin/gnome-keyring-daemon --start --components=pkcs11,secrets,ssh)"' ''
        ];

        monitor =
          if (hostName == "odin") then
            [
              "eDP-1,highres,100x0,1"
              # "HDMI-A-1,2560x1440@59.95,0x0,1"
              "HDMI-A-1,preferred,auto,1,mirror,eDP-1"
            ]
          else if (hostName == "axilon") then
            [
              "eDP-1,highres,365x1440,1"
              "HDMI-A-1,2560x1440@59.95,0x0,1"
              "DP-1,1920x1080@60.00000,2285x1440,1"
            ]
          else
            [ "eDP-1,highres,100x0,1" ];

        "$mod" = "SUPER";
        "$terminal" = "kitty";
        "$menu" = "rofi -show drun";
        "$fileManager" = "nautilus";

        #
        # ========== Behavior ==========
        #
        env = [
          "QT_QPA_PLATFORMTHEME,qt5ct"
          "MOZ_ENABLE_WAYLAND, 1"
          "MOZ_WEBRENDER, 1"
          "XDG_SESSION_TYPE,wayland"
          "WLR_NO_HARDWARE_CURSORS,1"
          "WLR_RENDERER_ALLOW_SOFTWARE,1"
          "QT_QPA_PLATFORM,wayland"
          "GNOME_KEYRING_CONTROL,/run/user/1000/keyring"
          "SSH_AUTH_SOCK,/run/user/1000/keyring/ssh"
        ];

        binds = {
          workspace_center_on = 1;
          movefocus_cycles_fullscreen = false;
        };

        input = {
          kb_layout = "us,ro";
          kb_options = "grp:alt_shift_toggle,lv3:ralt_switch";

          natural_scroll = false;
          touchpad = {
            natural_scroll = true;
            disable_while_typing = false;
          };
        };

        cursor = {
          inactive_timeout = 10;
        };

        misc = {
          disable_hyprland_logo = true;
          animate_manual_resizes = true;
          animate_mouse_windowdragging = true;
          new_window_takes_over_fullscreen = 2;
          middle_click_paste = false;
        };

        #
        # ========== Appearance ==========
        #
        general = {
          "gaps_in" = 6;
          "gaps_out" = 12;
          "border_size" = 1;

          # "col.active_border" = "rgba(9e5cafee) rgba(c567dcee) 45deg";
          # "col.inactive_border" = "rgba(595959aa)";

          "allow_tearing" = true;
          "resize_on_border" = true;
          "hover_icon_on_border" = true;
        };

        decoration = {
          rounding = 8;
          active_opacity = 1.0;
          inactive_opacity = 0.85;
          fullscreen_opacity = 1.0;

          blur = {
            enabled = true;
            size = 4;
            passes = 2;
            new_optimizations = true;
            popups = true;
          };

          shadow.enabled = true;
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
          pseudotile = true;
        };

        gestures = {
          workspace_swipe = true;
          workspace_swipe_fingers = 3;
        };

        #
        # ========== Window Rules ==========
        #
        windowrule = [
          "float,stayfocused,focus,center,class:(Rofi),title:(rofi - drun)"

          # Dialogs
          "float, title:^(Open File)(.*)$"
          "float, title:^(Select a File)(.*)$"
          "float, title:^(Choose wallpaper)(.*)$"
          "float, title:^(Open Folder)(.*)$"
          "float, title:^(Save As)(.*)$"
          "float, title:^(Library)(.*)$"
          "float, title:^(Accounts)(.*)$"
        ];

        windowrulev2 = [
          "float, class:^(galculator)$"
          "float, class:^(waypaper)$"
          "float, class:^(keymapp)$"

          #
          # ========== Screenshot App =========
          #
          "float,        class:^(com.gabm.satty)$"
          "size 50% 50%, class:^(com.gabm.satty)$"
          "center,       class:^(com.gabm.satty)$"

          #
          # ========== Picture-in-Picture ==========
          #
          "float,        title:^(Picture-in-Picture)$"
          "size 30% 30%, title:^(Picture-in-Picture)$"
          "center,       title:^(Picture-in-Picture)$"
          "pin,         title:^(Picture-in-Picture)$"

          #
          # ========== Always opaque ==========
          #
          "opaque, class:^([Gg]imp)$"
          "opaque, class:^([Ff]lameshot)$"
          "opaque, class:^([Ii]nkscape)$"
          "opaque, class:^([Bb]lender)$"
          "opaque, class:^([Oo][Bb][Ss])$"
          "opaque, class:^([Ss]team)$"
          "opaque, class:^([Ss]team_app_*)$"
          "opaque, class:^([Vv]lc)$"

          # Remove transparency from video
          "opaque, title:^(Netflix)(.*)$"
          "opaque, title:^(.*YouTube.*)$"
          "opaque, title:^(Picture-in-Picture)$"

          # Steam rules
          "stayfocused, title:^()$,class:^([Ss]team)$"
          "minsize 1 1, title:^()$,class:^([Ss]team)$"
          "immediate, class:^([Ss]team_app_*)$"

          # JetBrains IDEs
          "opaque, class:^(jetbrains-.*)$"
          "noinitialfocus, class:^(jetbrains-.*)$, title:^$, initialTitle:^$, floating:1"
          "stayfocused, class:^(jetbrains-.*)$, title:^$, floating:1"
          "nofocus, class:^(jetbrains-.*)$, title:^(win.*)$, floating:1"
        ];

        bind = [
          "$mod, B, exec, app.zen_browser.zen"
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

          "$mod, S, togglespecialworkspace, magic"
          "$mod SHIFT, S, movetoworkspace, special:magic"

          "$mod, mouse_down, workspace, e+1"
          "$mod, mouse_up, workspace, e-1"

          "$mod Control_L, left, workspace, e-1"
          "$mod Control_L, right, workspace, e+1"
          "$mod SHIFT, left, movetoworkspace, e-1"
          "$mod SHIFT, right, movetoworkspace, e+1"

          "$mod, Tab , cyclenext, "
          "$mod, Tab, bringactivetotop, "

          "$mod&Alt, F, fullscreen,"
        ]
        ++ (builtins.concatLists (
          builtins.genList (
            i:
            let
              ws = i + 1;
            in
            [
              "$mod, code:1${toString i}, workspace, ${toString ws}"
              "$mod SHIFT, code:1${toString i}, movetoworkspace, ${toString ws}"
            ]
          ) 10
        ));

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
          ", XF86AudioRaiseVolume, exec, nosh volume-up"
          ", XF86AudioLowerVolume, exec, nosh volume-down"
          ", XF86MonBrightnessUp, exec, nosh brightness-up"
          ", XF86MonBrightnessDown, exec, nosh brightness-down"

          ", XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
          ", Print, exec, $HOME/.config/hypr/scripts/screenshot_utils.sh region"
          "Alt, Print, exec, $HOME/.config/hypr/scripts/screenshot_utils.sh window"
          "$mod, Print, exec, $HOME/.config/hypr/scripts/screenshot_utils.sh full"
        ];
      };
    };
  };
}
