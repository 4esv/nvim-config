" Bridge for rileytwo/kiss: it ships its Neovim colorscheme at nvim/kiss.vim
" (not the standard colors/ dir), so :colorscheme kiss can't find it directly.
" vim.pack puts the repo root on the runtimepath, so source it from there.
runtime nvim/kiss.vim
