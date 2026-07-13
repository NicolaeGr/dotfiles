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
