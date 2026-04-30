local parser_config = require("nvim-treesitter.parsers").get_parser_configs()

parser_config.tyna = {
  install_info = {
    url = "https://github.com/tynalang/tree-sitter-tyna",
    files = {"src/parser.c"},
    branch = "main",
  },
  filetype = "tn",
}

-- Ensure Neovim recognizes .tn files
vim.filetype.add({
  extension = {
    tn = "tyna",
  },
})
