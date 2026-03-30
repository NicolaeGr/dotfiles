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

require("lazy").setup({
  spec = {
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },

    { import = "lazyvim.plugins.extras.coding.mini-comment" },
    { import = "lazyvim.plugins.extras.coding.mini-surround" },
    { import = "lazyvim.plugins.extras.dap.core" },
    { import = "lazyvim.plugins.extras.dap.nlua" },
    -- We need to use Edgy before Aerial
    { import = "lazyvim.plugins.extras.ui.edgy" },
    { import = "lazyvim.plugins.extras.editor.aerial" },
    { import = "lazyvim.plugins.extras.editor.illuminate" },
    { import = "lazyvim.plugins.extras.editor.inc-rename" },
    { import = "lazyvim.plugins.extras.editor.leap" },
    { import = "lazyvim.plugins.extras.editor.mini-diff" },
    { import = "lazyvim.plugins.extras.editor.navic" },
    { import = "lazyvim.plugins.extras.editor.overseer" },
    { import = "lazyvim.plugins.extras.lang.clangd" },
    { import = "lazyvim.plugins.extras.lang.docker" },
    { import = "lazyvim.plugins.extras.lang.helm" },
    { import = "lazyvim.plugins.extras.lang.json" },
    { import = "lazyvim.plugins.extras.lang.markdown" },
    { import = "lazyvim.plugins.extras.lang.nushell" },
    { import = "lazyvim.plugins.extras.lang.python" },
    { import = "lazyvim.plugins.extras.lang.rust" },
    { import = "lazyvim.plugins.extras.lang.terraform" },
    { import = "lazyvim.plugins.extras.lang.yaml" },
    { import = "lazyvim.plugins.extras.lsp.neoconf" },
    { import = "lazyvim.plugins.extras.lsp.none-ls" },
    { import = "lazyvim.plugins.extras.test.core" },
    { import = "lazyvim.plugins.extras.ui.mini-animate" },
    { import = "lazyvim.plugins.extras.ui.treesitter-context" },
    { import = "lazyvim.plugins.extras.util.startuptime" },
    -- import/override with your plugins
    { import = "plugins" },
  },
  defaults = {
    lazy = false,
    version = false,
  },
  install = { colorscheme = { "catppuccin", "habamax" } },
  checker = {
    enabled = true,
    notify = false,
  },
  performance = {
    rtp = {
      -- disable some rtp plugins
      disabled_plugins = {
        "gzip",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})
