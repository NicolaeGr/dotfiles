hl.on("hyprland.start", function()
    hl.exec_cmd("ht reload")
end)

hl.on("config.reloaded", function()
    hl.exec_cmd("ht reload --if-changed")
end)
