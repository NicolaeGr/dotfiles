-- Open Telescope on folder enter
vim.cmd([[
  autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) | bdelete | execute 'Telescope find_files' | endif
]])


-- Format code on save
vim.cmd([[autocmd BufWritePre * silent! :Format]])

-- Format code on paste
vim.cmd([[autocmd TextYankPost * silent! :Format]])

-- Toggle highlight
-- vim.cmd([[command! HiLiToggle (g:hlsearch ? ':nohls' : ':set hls')]])

-- Remove trailing whitespaces
-- (if a file requires trailing spaces, exclude its type using the regex)
vim.cmd [[autocmd BufWritePre * %s/\s\+$//e ]]

-- Automatically load zshrc file
vim.cmd([[set shellcmdflag=-lic]])

-- Swap folder
-- vim.cmd('command! ListSwap split | enew | r !ls -l ~/.local/share/nvim/swap')
-- vim.cmd('command! CleanSwap !rm -rf ~/.local/state/nvim/swap/')

-- Open help tags
-- vim.cmd('command! HelpTags Telescope help_tags')

-- Create ctags
-- vim.cmd('command! MakeCTags !ctags -R --exclude=@.ctagsignore .')
