hl.on("hyprland.start", function()
    hl.exec_cmd("ht reload")
end)

-- A rebuild rewrites hyprland.lua when the ht store path changes, which makes
-- Hyprland reload this config. Reapply then, but leave the theme alone if it
-- is already the one marked as applied.
hl.on("config.reloaded", function()
    hl.exec_cmd("ht reload --if-changed")
end)
