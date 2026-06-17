-- ===========================================================================
-- Neovim 0.12 + vim.pack trial config.
-- Slimmed port of Axel's NormalNvim fork (~122 plugins -> ~60), lazy.nvim
-- replaced by the native vim.pack manager.
--
-- Load order matters: leader before plugins/keymaps; plugins (which load
-- everything via vim.pack.add) before lsp which requires them. Debugger and
-- test runner are set up once Neovim goes idle (not needed at first paint).
-- ===========================================================================

vim.g.mapleader = " "
vim.g.maplocalleader = ","

-- Disable unused built-in runtime plugins (small startup win, no feature loss).
for _, p in ipairs({
  "gzip", "tarPlugin", "zipPlugin", "tohtml", "tutor",
  "netrwPlugin", "rplugin", "spellfile", "matchit",
}) do
  vim.g["loaded_" .. p] = 1
end

vim.loader.enable()

local function load(mod)
  local ok, err = pcall(require, mod)
  if not ok then
    vim.api.nvim_echo({ { "Failed to load " .. mod .. "\n\n" .. err } }, true, { err = true })
  end
end

load("config.options")
load("config.plugins") -- vim.pack.add + setups (loads every plugin)
load("config.lsp")     -- mason + native LSP + conform + nvim-lint
load("config.keymaps")
load("config.autocmds")

-- Heavier, on-demand subsystems: set up the instant Neovim goes idle.
vim.schedule(function()
  load("config.debug") -- nvim-dap + dap-ui
  load("config.test")  -- neotest + coverage
end)
