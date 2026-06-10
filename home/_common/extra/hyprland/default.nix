{
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
    ./awww
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
    extra.hyprland.awww.enable = true;
    extra.hyprland.nosh.enable = true;

    home.packages = with pkgs; [
      libnotify
    ];

    wayland.windowManager.hyprland = {
      enable = true;
      configType = "lua";

      systemd = {
        enable = false;
        variables = [ "--all" ];
      };

      settings = { };

      extraConfig = ''
        --
        -- ========== Variables ==========
        --
        local mod = "SUPER"
        local terminal = "kitty"
        local fileManager = "nautilus"

        --
        -- ========== Environment ==========
        --
        hl.config({
            env = {
                "QT_QPA_PLATFORMTHEME,qt5ct",
                "MOZ_ENABLE_WAYLAND,1",
                "MOZ_WEBRENDER,1",
                "XDG_SESSION_TYPE,wayland",
                "WLR_NO_HARDWARE_CURSORS,1",
                "WLR_RENDERER_ALLOW_SOFTWARE,1",
                "QT_QPA_PLATFORM,wayland",
                "GNOME_KEYRING_CONTROL,/run/user/1000/keyring",
                "SSH_AUTH_SOCK,/run/user/1000/keyring/ssh"
            }
        })

        --
        -- ========== Autostart ==========
        --
        hl.on("hyprland.start", function()
            hl.exec_cmd("${pkgs.dbus}/bin/dbus-update-activation-environment --systemd --all")
            hl.exec_cmd([=[${pkgs.bash}/bin/bash -c 'eval "$(${pkgs.gnome-keyring}/bin/gnome-keyring-daemon --start --components=pkcs11,secrets,ssh)"']=])
        end)

        --
        -- ========== Monitors ==========
        --
        ${
          if hostName == "odin" then
            ''
              hl.monitor({ output = "eDP-1", mode = "highres", position = "100x0", scale = 1 })
              hl.monitor({ output = "HDMI-A-1", mode = "preferred", position = "auto", scale = 1, mirror = "eDP-1" })
            ''
          else if hostName == "zoln" then
            ''
              hl.monitor({ output = "DP-1", mode = "2560x1440@180", position = "0x0", scale = 1 })
            ''
          else
            ''
              hl.monitor({ output = "eDP-1", mode = "highres", position = "100x0", scale = 1 })
            ''
        }

        --
        -- ========== Behavior & Appearance ==========
        --
        hl.config({
            binds = {
                workspace_center_on = 1,
                movefocus_cycles_fullscreen = false,
            },
            input = {
                kb_layout = "ro,ru",
                kb_options = "grp:alt_shift_toggle,lv3:ralt_switch",
                natural_scroll = false,
                touchpad = {
                    natural_scroll = true,
                    disable_while_typing = false,
                }
            },
            cursor = {
                inactive_timeout = 10,
            },
            misc = {
                disable_hyprland_logo = true,
                animate_manual_resizes = true,
                animate_mouse_windowdragging = true,
                middle_click_paste = false,
            },
            general = {
                gaps_in = 6,
                gaps_out = 12,
                border_size = 1,
                allow_tearing = true,
                resize_on_border = true,
                hover_icon_on_border = true,
            },
            decoration = {
                rounding = 8,
                active_opacity = 1.0,
                inactive_opacity = 0.85,
                fullscreen_opacity = 1.0,
                blur = {
                    enabled = true,
                    size = 4,
                    passes = 2,
                    new_optimizations = true,
                    popups = true,
                },
                shadow = {
                    enabled = true,
                }
            },
            animations = {
                enabled = true,
                bezier = { "myBezier, 0.05, 0.9, 0.1, 1.05" },
                animation = {
                    "windows, 1, 7, myBezier",
                    "windowsOut, 1, 7, default, popin 80%",
                    "border, 1, 10, default",
                    "borderangle, 1, 8, default",
                    "fade, 1, 7, default",
                    "workspaces, 1, 6, default",
                }
            }
        })

        -- Gestures are handled via the top-level hl.gesture function
        hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

        --
        -- ========== Window Rules ==========
        --
        local float_titles = { "^(Open File)(.*)$", "^(Select a File)(.*)$", "^(Choose wallpaper)(.*)$", "^(Open Folder)(.*)$", "^(Save As)(.*)$", "^(Library)(.*)$", "^(Accounts)(.*)$" }
        for _, title_match in ipairs(float_titles) do
            hl.window_rule({ match = { title = title_match }, float = true })
        end

        local float_classes = { "^(galculator)$", "^(waypaper)$", "^(keymapp)$" }
        for _, class_match in ipairs(float_classes) do
            hl.window_rule({ match = { class = class_match }, float = true })
        end

        hl.window_rule({ match = { class = "^(com.gabm.satty)$" }, float = true, size = "50% 50%", center = true })
        hl.window_rule({ match = { title = "^(Picture-in-Picture)$" }, float = true, size = "30% 30%", center = true, pin = true, opaque = true })

        local opaque_classes = { "^([Gg]imp)$", "^([Ff]lameshot)$", "^([Ii]inkscape)$", "^([Bb]lender)$", "^([Oo][Bb][Ss])$", "^([Vv]lc)$" }
        for _, class_match in ipairs(opaque_classes) do
            hl.window_rule({ match = { class = class_match }, opaque = true })
        end

        hl.window_rule({ match = { title = "^(Netflix)(.*)$" }, opaque = true })
        hl.window_rule({ match = { title = "^(.*YouTube.*)$" }, opaque = true })

        hl.window_rule({ match = { class = "^([Ss]team)$" }, opaque = true })
        hl.window_rule({ match = { title = "^()$", class = "^([Ss]team)$" }, stay_focused = true, min_size = "1 1" })
        hl.window_rule({ match = { class = "^([Ss]team_app_*)$" }, opaque = true, immediate = true })

        hl.window_rule({ match = { class = "^(jetbrains-.*)$" }, opaque = true })
        hl.window_rule({ match = { class = "^(jetbrains-.*)$", title = "^$", initial_title = "^$", float = true }, no_initial_focus = true, stay_focused = true })
        hl.window_rule({ match = { class = "^(jetbrains-.*)$", title = "^(win.*)$", float = true }, no_focus = true })

        --
        -- ========== Core Binds ==========
        --
        hl.bind(mod .. " + B", hl.dsp.exec_cmd("app.zen_browser.zen"))
        hl.bind(mod .. " + T", hl.dsp.exec_cmd(terminal))
        hl.bind(mod .. " + Q", hl.dsp.window.close())
        hl.bind(mod .. " + L", hl.dsp.exec_cmd("hyprlock"))
        hl.bind(mod .. " + SHIFT + L", hl.dsp.exec_cmd("hyprlock"))
        hl.bind(mod .. " + F", hl.dsp.exec_cmd(fileManager))
        hl.bind(mod .. " + V", hl.dsp.window.float({ action = "toggle" }))
        hl.bind(mod .. " + P", hl.dsp.window.pseudo({ action = "toggle" }))
        hl.bind(mod .. " + J", hl.dsp.layout("togglesplit"))

        -- Move Focus
        hl.bind(mod .. " + left", hl.dsp.focus({ direction = "l" }))
        hl.bind(mod .. " + right", hl.dsp.focus({ direction = "r" }))
        hl.bind(mod .. " + up", hl.dsp.focus({ direction = "u" }))
        hl.bind(mod .. " + down", hl.dsp.focus({ direction = "d" }))

        -- Special Workspace
        hl.bind(mod .. " + S", hl.dsp.workspace.toggle_special("magic"))
        hl.bind(mod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))

        -- Mouse Scroll & Directional Workspaces
        hl.bind(mod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
        hl.bind(mod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))
        hl.bind(mod .. " + Control_L + left", hl.dsp.focus({ workspace = "e-1" }))
        hl.bind(mod .. " + Control_L + right", hl.dsp.focus({ workspace = "e+1" }))
        hl.bind(mod .. " + SHIFT + left", hl.dsp.window.move({ workspace = "e-1" }))
        hl.bind(mod .. " + SHIFT + right", hl.dsp.window.move({ workspace = "e+1" }))

        -- Chained / Sequential Binds (Requires anonymous function wrapper)
        hl.bind(mod .. " + Tab", function()
            hl.dispatch(hl.dsp.window.cycle_next())
            hl.dispatch(hl.dsp.window.bring_to_top())
        end)
        hl.bind(mod .. " + ALT + F", hl.dsp.window.fullscreen({ action = "toggle" }))

        --
        -- ========== Workspace Loop ==========
        --
        -- Maps 1->code:10, 9->code:18, 10->code:19 (the 0 key)
        for i = 1, 10 do
            local ws = tostring(i)
            local keycode = "code:" .. tostring(9 + i)
            hl.bind(mod .. " + " .. keycode, hl.dsp.focus({ workspace = ws }))
            hl.bind(mod .. " + SHIFT + " .. keycode, hl.dsp.window.move({ workspace = ws }))
        end

        --
        -- ========== Mouse & Media Binds ==========
        --
        hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
        hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })
        hl.bind(mod .. " + SHIFT + mouse:273", hl.dsp.window.resize(), { mouse = true })

        hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
        hl.bind(mod .. " + SHIFT + L", hl.dsp.exec_cmd("sleep 0.1 && systemctl suspend"), { locked = true })

        hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true, repeating = true })
        hl.bind("Print", hl.dsp.exec_cmd([[$HOME/.config/hypr/scripts/screenshot_utils.sh region]]), { locked = true, repeating = true })
        hl.bind("ALT + Print", hl.dsp.exec_cmd([[$HOME/.config/hypr/scripts/screenshot_utils.sh window]]), { locked = true, repeating = true })
        hl.bind(mod .. " + Print", hl.dsp.exec_cmd([[$HOME/.config/hypr/scripts/screenshot_utils.sh full]]), { locked = true, repeating = true })
      '';
    };
  };
}
