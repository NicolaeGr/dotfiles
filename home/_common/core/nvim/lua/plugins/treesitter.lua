return {
	"nvim-treesitter/nvim-treesitter",
	lazy = false,
	build = ":TSUpdate",
	config = function()
		-- Register custom parser
		vim.api.nvim_create_autocmd("User", {
			pattern = "TSUpdate",
			callback = function()
				require("nvim-treesitter.parsers").tyna = {
					install_info = {
						url = "https://github.com/tynalang/tree-sitter-tyna",
						revision = "main",
					},
					filetype = "tn",
					tier = 2,
				}
			end,
		})

		-- Register filetype if needed
		vim.treesitter.language.register("tyna", "tn")

		vim.filetype.add({
			extension = {
				tn = "tyna",
			},
		})
	end,
}
