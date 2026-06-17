-- UI toggle helpers for the <leader>u… keymaps.
-- Reimplemented from NormalNvim's base/utils/ui.lua, trimmed to what we map.

local M = {}

local function notify(msg, enabled)
  vim.notify(msg .. (enabled and " on" or " off"), vim.log.levels.INFO)
end

function M.toggle_autopairs()
  vim.g.minipairs_disable = not vim.g.minipairs_disable
  notify("autopairs", not vim.g.minipairs_disable)
end

function M.toggle_background()
  vim.o.background = vim.o.background == "dark" and "light" or "dark"
  notify("background " .. vim.o.background, true)
end

function M.toggle_cmp()
  vim.g.cmp_enabled = not vim.g.cmp_enabled
  notify("completion", vim.g.cmp_enabled)
end

function M.toggle_css_colors()
  vim.cmd("HighlightColors Toggle")
end

function M.toggle_diagnostics()
  vim.g.diagnostics_mode = (vim.g.diagnostics_mode + 1) % 4
  vim.diagnostic.config({
    virtual_text = vim.g.diagnostics_mode >= 3,
    underline = vim.g.diagnostics_mode >= 2,
    signs = vim.g.diagnostics_mode >= 1,
  })
  vim.notify("diagnostics mode " .. vim.g.diagnostics_mode, vim.log.levels.INFO)
end

function M.toggle_signcolumn()
  vim.wo.signcolumn = vim.wo.signcolumn == "no" and "yes" or "no"
  notify("signcolumn", vim.wo.signcolumn ~= "no")
end

function M.toggle_statusline()
  local on = vim.o.laststatus == 0
  vim.o.laststatus = on and 3 or 0
  notify("statusline", on)
end

function M.toggle_line_numbers()
  vim.wo.number = not vim.wo.number
  notify("line numbers", vim.wo.number)
end

function M.toggle_notifications()
  vim.g.notifications_enabled = not vim.g.notifications_enabled
end

function M.toggle_paste()
  vim.o.paste = not vim.o.paste
  notify("paste mode", vim.o.paste)
end

function M.toggle_spell()
  vim.wo.spell = not vim.wo.spell
  notify("spell", vim.wo.spell)
end

function M.toggle_conceal()
  vim.wo.conceallevel = vim.wo.conceallevel == 0 and 2 or 0
  notify("conceal", vim.wo.conceallevel ~= 0)
end

function M.toggle_tabline()
  local on = vim.o.showtabline == 0
  vim.o.showtabline = on and 2 or 0
  notify("tabline", on)
end

function M.set_tabulation()
  vim.ui.input({ prompt = "Set tab width: ", default = tostring(vim.bo.shiftwidth) }, function(v)
    local n = tonumber(v)
    if n then
      vim.bo.tabstop, vim.bo.shiftwidth, vim.bo.softtabstop = n, n, n
      vim.notify("tab width " .. n, vim.log.levels.INFO)
    end
  end)
end

function M.toggle_url_hl()
  vim.g.url_hl_enabled = not vim.g.url_hl_enabled
  notify("URL highlight", vim.g.url_hl_enabled)
end

function M.toggle_wrap()
  vim.wo.wrap = not vim.wo.wrap
  notify("wrap", vim.wo.wrap)
end

function M.toggle_buffer_syntax()
  local on = vim.bo.syntax == "OFF" or vim.b.ts_highlight == false
  if on then
    pcall(vim.treesitter.start)
    vim.bo.syntax = "on"
  else
    pcall(vim.treesitter.stop)
    vim.bo.syntax = "off"
  end
  notify("syntax", on)
end

function M.toggle_foldcolumn()
  vim.wo.foldcolumn = vim.wo.foldcolumn == "0" and "1" or "0"
  notify("foldcolumn", vim.wo.foldcolumn ~= "0")
end

function M.toggle_lsp_signature()
  vim.g.lsp_signature_enabled = not vim.g.lsp_signature_enabled
  pcall(function() require("lsp_signature").toggle_float_win() end)
  notify("LSP signature", vim.g.lsp_signature_enabled)
end

function M.toggle_animations()
  vim.g.minianimate_disable = not vim.g.minianimate_disable
  notify("animations", not vim.g.minianimate_disable)
end

function M.toggle_zen_mode()
  vim.cmd("ZenMode")
end

function M.toggle_codelens()
  vim.g.codelens_enabled = not vim.g.codelens_enabled
  if not vim.g.codelens_enabled then vim.lsp.codelens.clear() end
  notify("codelens", vim.g.codelens_enabled)
end

function M.toggle_autoformat()
  vim.g.autoformat_enabled = not vim.g.autoformat_enabled
  notify("autoformat (global)", vim.g.autoformat_enabled)
end

function M.toggle_buffer_autoformat()
  local cur = vim.b.autoformat_enabled
  if cur == nil then cur = vim.g.autoformat_enabled end
  vim.b.autoformat_enabled = not cur
  notify("autoformat (buffer)", vim.b.autoformat_enabled)
end

function M.toggle_buffer_inlay_hints(bufnr)
  bufnr = bufnr or 0
  local on = not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr })
  vim.lsp.inlay_hint.enable(on, { bufnr = bufnr })
  notify("inlay hints", on)
end

function M.toggle_coverage_signs()
  pcall(function() require("coverage").toggle() end)
end

return M
