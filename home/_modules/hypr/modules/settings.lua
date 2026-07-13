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

hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
