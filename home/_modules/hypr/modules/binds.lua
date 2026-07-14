local vars = require("modules.vars")
local mod = vars.mod

-- Core Binds
hl.bind(mod .. " + B", hl.dsp.exec_cmd("app.zen_browser.zen"))
hl.bind(mod .. " + T", hl.dsp.exec_cmd(vars.terminal))
hl.bind(mod .. " + Q", hl.dsp.window.close())
hl.bind(mod .. " + L", hl.dsp.exec_cmd("hyprlock"))
hl.bind(mod .. " + SHIFT + L", hl.dsp.exec_cmd("hyprlock"))
hl.bind(mod .. " + F", hl.dsp.exec_cmd(vars.fileManager))
hl.bind(mod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mod .. " + P", hl.dsp.window.pseudo({ action = "toggle" }))
hl.bind(mod .. " + J", hl.dsp.layout("togglesplit"))

-- Nosh Binds
hl.bind("SUPER + X", hl.dsp.exec_cmd("nosh app-launcher"))

hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("nosh volume-up"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("nosh volume-down"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("nosh brightness-up"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("nosh brightness-down"), { locked = true, repeating = true })

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

-- Chained / Sequential Binds
hl.bind(mod .. " + Tab", function()
    hl.dispatch(hl.dsp.window.cycle_next())
    hl.dispatch(hl.dsp.window.bring_to_top())
end)
hl.bind(mod .. " + ALT + F", hl.dsp.window.fullscreen({ action = "toggle" }))

-- Workspace Loop
for i = 1, 10 do
    local ws = tostring(i)
    local keycode = "code:" .. tostring(9 + i)
    hl.bind(mod .. " + " .. keycode, hl.dsp.focus({ workspace = ws }))
    hl.bind(mod .. " + SHIFT + " .. keycode, hl.dsp.window.move({ workspace = ws }))
end

-- Mouse & Media Binds
hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })
hl.bind(mod .. " + SHIFT + mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true })
hl.bind(mod .. " + SHIFT + L", hl.dsp.exec_cmd("sleep 0.1 && systemctl suspend"), { locked = true })

hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true, repeating = true })
hl.bind("Print", hl.dsp.exec_cmd([[$HOME/.config/hypr/scripts/screenshot_utils.sh region]]), { locked = true, repeating = true })
hl.bind("ALT + Print", hl.dsp.exec_cmd([[$HOME/.config/hypr/scripts/screenshot_utils.sh window]]), { locked = true, repeating = true })
hl.bind(mod .. " + Print", hl.dsp.exec_cmd([[$HOME/.config/hypr/scripts/screenshot_utils.sh full]]), { locked = true, repeating = true })
