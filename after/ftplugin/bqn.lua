-- BQN buffer-local settings (ported; rtp path repointed to vim.pack).

-- Ensure BQN vim support (keymap, syntax) is on the rtp.
local hits = vim.fn.globpath(vim.fn.stdpath("data") .. "/site/pack", "*/opt/BQN/editors/vim", false, true)
local bqn_vim_dir = hits[1]
if bqn_vim_dir and vim.fn.isdirectory(bqn_vim_dir) == 1 then
  if not vim.tbl_contains(vim.opt.rtp:get(), bqn_vim_dir) then
    vim.opt.rtp:append(bqn_vim_dir)
  end
end

-- Glyph input via BQN keymap (\ prefix in insert mode, e.g. \t -> ⊢)
vim.bo.keymap = "bqn"
vim.bo.iminsert = 1

-- Indentation
vim.bo.shiftwidth = 2
vim.bo.tabstop = 2
vim.bo.softtabstop = 2
vim.bo.expandtab = true

-- Comments
vim.bo.commentstring = "#%s"

-- Match BQN angle brackets
vim.opt_local.matchpairs:append("⟨:⟩")

-- Remap nvim-bqn functions under <leader>B (avoid clashing with buffer/CR maps).
local ok, bqn = pcall(require, "bqn")
if not ok then
  vim.notify("nvim-bqn not loaded: " .. tostring(bqn), vim.log.levels.WARN)
  return
end

local map = vim.keymap.set
local bo = { buffer = true }

map("n", "<leader>Br", function() bqn.evalBQN(0, vim.fn.line("."), false) end,
  vim.tbl_extend("force", bo, { desc = "BQN eval to cursor (inline)" }))
map("x", "<leader>Br", ":BQNEvalRange<CR>",
  vim.tbl_extend("force", bo, { desc = "BQN eval selection (inline)" }))
map("n", "<leader>Bf", "<cmd>BQNEvalFile<cr>",
  vim.tbl_extend("force", bo, { desc = "BQN eval full file (inline)" }))
map("n", "<leader>Be", function() bqn.evalBQN(vim.fn.line(".") - 1, vim.fn.line("."), true) end,
  vim.tbl_extend("force", bo, { desc = "BQN explain expression" }))
map("n", "<leader>Bc", function() bqn.clearBQN(vim.fn.line(".") - 1, -1) end,
  vim.tbl_extend("force", bo, { desc = "BQN clear from cursor" }))
map("n", "<leader>BC", "<cmd>BQNClearFile<cr>",
  vim.tbl_extend("force", bo, { desc = "BQN clear all results" }))

-- Remove nvim-bqn's default mappings that conflict.
pcall(vim.keymap.del, "n", "<CR>", { buffer = true })
pcall(vim.keymap.del, "x", "<CR>", { buffer = true })
pcall(vim.keymap.del, "n", "<leader>bf", { buffer = true })
pcall(vim.keymap.del, "n", "<leader>bc", { buffer = true })
pcall(vim.keymap.del, "n", "<leader>bC", { buffer = true })
pcall(vim.keymap.del, "n", "<leader>be", { buffer = true })
pcall(vim.keymap.del, "x", "<leader>bc", { buffer = true })
