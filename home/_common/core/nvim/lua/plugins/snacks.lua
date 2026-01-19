local flakeRoot = vim.g.flake_root
local configCwd = flakeRoot or vim.fn.stdpath('config')

local function open_config()
  require("telescope.builtin").find_files({
    cwd = configCwd,
    attach_mappings = function(prompt_bufnr, map)
      local actions = require("telescope.actions")
      local action_state = require("telescope.actions.state")

      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        if selection then
          vim.cmd('cd ' .. configCwd)
          vim.notify('Opened config folder at ' .. configCwd, vim.log.levels.INFO)
          vim.cmd('edit ' .. selection.value)
        end
      end)
      return true
    end
  })
end

local function list_lua_roots()
  local roots = {}
  for _, f in ipairs(vim.api.nvim_get_runtime_file("lua/*", true)) do
    local m = f:match(".*/lua/([^/]+)")
    if m then
      roots[m] = true
    end
  end

  local keys = vim.tbl_keys(roots)
  table.sort(keys)

  vim.notify(
    "Lua roots:\n" .. table.concat(keys, "\n"),
    vim.log.levels.INFO,
    { title = "Lua runtime" }
  )
end


return {
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    ---@type snacks.Config
    opts = {
      dashboard = {
        preset = {
          pick = function(cmd, opts)
            return LazyVim.pick(cmd, opts)()
          end,
          header = [[
          ██████╗ ██████╗ ██████╗ ███████╗    ██████╗ ██████╗  ██████╗
          ██╔════╝██╔═══██╗██╔══██╗██╔════╝    ██╔══██╗██╔══██╗██╔═══██╗
          ██║     ██║   ██║██║  ██║█████╗      ██████╔╝██████╔╝██║   ██║
          ██║     ██║   ██║██║  ██║██╔══╝      ██╔══██╗██╔══██╗██║   ██║
          ╚██████╗╚██████╔╝██████╔╝███████╗    ██████╔╝██║  ██║╚██████╔╝
          ╚═════╝ ╚═════╝ ╚═════╝ ╚══════╝    ╚═════╝ ╚═╝  ╚═╝ ╚═════╝
          ]],
          -- stylua: ignore
          ---@type snacks.dashboard.Item[]
          keys = {
            { key = "L", desc = "List Lua modules", action = list_lua_roots },
            { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
            { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
            { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
            { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
            { icon = " ", key = "c", desc = "Config", action = open_config },
            { icon = " ", key = "s", desc = "Restore Session", section = "session" },
            { icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy" },
            { icon = " ", key = "q", desc = "Quit", action = ":qa" },
          },
        },
        sections = {
          { section = "header" },
          { section = "keys", padding = 1 },
          { title = "Projects" },
          { section = "projects", cwd = true, padding = 1 },
          { title = "Recent" },
          { section = "recent_files", cwd = true, limit = 8, padding = 1 },
        },
      },
      indent = { enabled = true },
      input = { enabled = true },
      notifier = { enabled = true },
      scope = { enabled = true },
      scroll = { enabled = true },
      statuscolumn = { enabled = false }, -- we set this in options.lua
      words = { enabled = true },
    },
    keys = {
      { "<leader>n", function()
        if Snacks.config.picker and Snacks.config.picker.enabled then
          Snacks.picker.notifications()
        else
          Snacks.notifier.show_history()
        end
      end, desc = "Notification History" },
      { "<leader>un", function() Snacks.notifier.hide() end, desc = "Dismiss All Notifications" },
    },
  },
}
