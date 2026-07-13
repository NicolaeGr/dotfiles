local bg_image = os.getenv("HOME") .. "/.config/hypr/backgrounds/galaxy.jpg"

hl.on("hyprland.start", function()
    hl.exec_cmd("awww-daemon &")
    hl.exec_cmd("awww img " .. bg_image)
end)
