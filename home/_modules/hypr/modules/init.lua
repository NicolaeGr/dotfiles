Vars = require("modules.vars")

require("modules.background")

require("modules.autostart")

require("modules.monitors")
require("modules.settings")
require("modules.rules")
require("modules.binds")

-- ht: load the active theme last so it can override the base config.
local theme_path = os.getenv("HOME") .. "/.local/state/ht/active/hyprland.lua"
local theme_file = io.open(theme_path, "r")
if theme_file then
  theme_file:close()
  dofile(theme_path)
end
