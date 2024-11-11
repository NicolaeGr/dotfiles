-- Plugin definition and loading
-- local execute = vim.api.nvim_command
local fn = vim.fn
local cmd = vim.cmd

-- Install package manager
--    https://github.com/folke/lazy.nvim
--    `:help lazy.nvim.txt` for more info
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup("plugins")
-- require('lazy').setup({
--   spec = {
--     -- { "LazyVim/LazyVim", import = "lazyvim.plugins" },
--     { import = "plugins" },
--   },
--   -- performance = {
--   --   reset_packpath = false,
--   --   rtp = {
--   --     reset = false,
--   --   }
--   -- },
--   install = {
--     missing = false,
--   },
--   checker = {
--     enabled = true, 
--     notify = false, 
--   }, 
-- })
