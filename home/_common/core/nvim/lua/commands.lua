-- Formatting
--vim.api.nvim_create_autocmd("BufWritePre", {
--	pattern = "*",
--	callback = function(args)
--		require("conform").format({
--			bufnr = args.buf,
--			async = false,
--			timeout_ms = 1000,
--		})
--	end,
--})

-- Toggle highlight
-- vim.cmd([[command! HiLiToggle (g:hlsearch ? ':nohls' : ':set hls')]])

-- Remove trailing whitespaces
-- (if a file requires trailing spaces, exclude its type using the regex)
vim.cmd([[autocmd BufWritePre * %s/\s\+$//e ]])

-- Automatically load zshrc file
vim.cmd([[set shellcmdflag=-lic]])

-- Swap folder
-- vim.cmd('command! ListSwap split | enew | r !ls -l ~/.local/share/nvim/swap')
-- vim.cmd('command! CleanSwap !rm -rf ~/.local/state/nvim/swap/')

-- Open help tags
-- vim.cmd('command! HelpTags Telescope help_tags')

-- Create ctags
-- vim.cmd('command! MakeCTags !ctags -R --exclude=@.ctagsignore .')
