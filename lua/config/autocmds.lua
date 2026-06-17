-- ===========================================================================
-- Autocmds & user commands ported from your NormalNvim 3-autocmds.lua and the
-- "special cases" block of 4-mappings.lua. The BaseFile/BaseGitFile/BaseDefered
-- user-event machinery is intentionally dropped — it only existed to drive
-- lazy.nvim's lazy-loading, which vim.pack does not use.
-- ===========================================================================

local autocmd = vim.api.nvim_create_autocmd
local cmd = vim.api.nvim_create_user_command

-- q closes help / man / quickfix / nofile / dap floats --------------------
autocmd("BufWinEnter", {
  desc = "Make q close help, man, quickfix, nofile",
  callback = function(args)
    local bt = vim.bo[args.buf].buftype
    if vim.tbl_contains({ "help", "nofile", "quickfix" }, bt) then
      vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = args.buf, silent = true, nowait = true })
    end
  end,
})
autocmd("CmdwinEnter", {
  desc = "Make q close command history",
  callback = function(args)
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = args.buf, silent = true, nowait = true })
  end,
})

-- Restore cursor position --------------------------------------------------
autocmd("BufReadPost", {
  desc = "Restore last cursor position",
  callback = function(args)
    local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
    local lines = vim.api.nvim_buf_line_count(args.buf)
    if mark[1] > 0 and mark[1] <= lines then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Create parent directories on save ---------------------------------------
autocmd("BufWritePre", {
  desc = "Create parent directories if missing when saving",
  callback = function(args)
    if vim.api.nvim_buf_is_valid(args.buf) and vim.bo[args.buf].buflisted then
      vim.fn.mkdir(vim.fn.fnamemodify(vim.uv.fs_realpath(args.match) or args.match, ":p:h"), "p")
    end
  end,
})

-- Unlist quickfix buffers --------------------------------------------------
autocmd("FileType", {
  desc = "Unlist quickfix buffers",
  pattern = "qf",
  callback = function() vim.opt_local.buflisted = false end,
})

-- URL underline effect -----------------------------------------------------
vim.api.nvim_set_hl(0, "HighlightURL", { underline = true })
local URL_PATTERN =
  [[\v\c%(%(h?ttps?|ftp|file|ssh|git)://|[a-z]+[@][a-z]+[.][a-z]+:)%(\S+(:\d+)?)+[/]?]]
autocmd({ "VimEnter", "FileType", "BufEnter", "WinEnter" }, {
  desc = "Highlight URLs",
  callback = function()
    if vim.w.url_match_id then
      pcall(vim.fn.matchdelete, vim.w.url_match_id)
      vim.w.url_match_id = nil
    end
    if vim.g.url_hl_enabled then
      vim.w.url_match_id = vim.fn.matchadd("HighlightURL", URL_PATTERN, 15)
    end
  end,
})

-- Right-click contextual menu ----------------------------------------------
autocmd("VimEnter", {
  desc = "Customize right-click menu",
  callback = function()
    pcall(vim.cmd, [[aunmenu PopUp.How-to\ disable\ mouse]])
    pcall(vim.cmd, [[aunmenu PopUp.-1-]])
    pcall(vim.cmd, [[menu PopUp.Format\ \Code <cmd>silent! Format<CR>]])
    pcall(vim.cmd, [[menu PopUp.-1- <Nop>]])
    pcall(vim.cmd, [[menu PopUp.Toggle\ \Breakpoint <cmd>lua require('dap').toggle_breakpoint()<CR>]])
    pcall(vim.cmd, [[menu PopUp.Run\ \Test <cmd>Neotest run<CR>]])
  end,
})

-- mini.indentscope: disable in special buffers -----------------------------
autocmd("FileType", {
  pattern = { "help", "neo-tree", "starter", "Trouble", "lazy", "mason", "toggleterm", "aerial" },
  callback = function() vim.b.miniindentscope_disable = true end,
})

-- ## COMMANDS --------------------------------------------------------------
cmd("TestNodejs", function()
  vim.cmd("ProjectRoot")
  vim.cmd("TermExec cmd='npm run test'")
end, { desc = "Run all unit tests for the current nodejs project" })

cmd("TestNodejsE2e", function()
  vim.cmd("ProjectRoot")
  vim.cmd("TermExec cmd='npm run e2e'")
end, { desc = "Run e2e tests for the current nodejs project" })

cmd("Cwd", function()
  vim.cmd("cd %:p:h")
  vim.cmd("pwd")
end, { desc = "cd current file's directory" })

cmd("WriteAllBuffers", function() vim.cmd("wa") end, { desc = "Write all changed buffers" })

-- vim.pack convenience commands --------------------------------------------
cmd("PackUpdate", function() vim.pack.update() end, { desc = "Update plugins (vim.pack)" })
cmd("PackStatus", function() vim.pack.update(nil, { offline = true }) end, { desc = "Show plugin status (no fetch)" })
