local function hostname()
    local file = io.open("/proc/sys/kernel/hostname", "r")
    if not file then
        return nil
    end
    local name = file:read("*l")
    file:close()
    return name
end

local host = hostname()

hl.monitor({ output = "eDP-1", mode = "highres", position = "100x0", scale = 1 })
hl.monitor({ output = "HDMI-A-1", mode = "preferred", position = "auto", scale = 1, mirror = "eDP-1" })

if host == "zoln" then
    hl.monitor({ output = "DP-1", mode = "2560x1440@180", position = "auto", scale = 1 })
end
