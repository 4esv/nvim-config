-- ===========================================================================
-- LSP (native vim.lsp.enable, no mason-lspconfig), formatting (conform),
-- linting (nvim-lint).  Servers/tools auto-installed via Mason for your langs.
-- ===========================================================================

require("mason").setup({ ui = { border = "rounded" } })

-- Mason package names (NOT lspconfig names) to ensure installed.
local mason_packages = {
  -- LSP servers
  "lua-language-server",
  "basedpyright",
  "ruff",
  "typescript-language-server",
  "html-lsp",
  "css-lsp",
  "eslint-lsp",
  "bash-language-server",
  "yaml-language-server",
  "json-lsp",
  -- formatters / linters
  "stylua",
  "prettierd",
  "shfmt",
  "shellcheck",
  "yamllint",
}

local function ensure_installed()
  local registry = require("mason-registry")
  for _, name in ipairs(mason_packages) do
    local ok, pkg = pcall(registry.get_package, name)
    if ok and not pkg:is_installed() then
      pkg:install()
    end
  end
end

-- Deferred off the startup path; servers install in the background.
vim.schedule(function()
  local ok, registry = pcall(require, "mason-registry")
  if ok and registry.refresh then
    registry.refresh(ensure_installed)
  else
    ensure_installed()
  end
end)

-- LSP servers to enable (these are nvim-lspconfig names; it ships lsp/<name>.lua
-- which vim.lsp.enable() activates on 0.11+).
local servers = {
  "lua_ls",
  "basedpyright",
  "ruff",
  "ts_ls",
  "html",
  "cssls",
  "eslint",
  "bashls",
  "yamlls",
  "jsonls",
}

-- Completion capabilities from blink.cmp, applied to every server.
local capabilities = vim.lsp.protocol.make_client_capabilities()
do
  local ok, blink = pcall(require, "blink.cmp")
  if ok then capabilities = blink.get_lsp_capabilities(capabilities) end
end
vim.lsp.config("*", { capabilities = capabilities })

-- Per-server tweaks.
vim.lsp.config("lua_ls", {
  settings = { Lua = { diagnostics = { globals = { "vim", "MiniIcons" } } } },
})

vim.lsp.enable(servers)

-- Diagnostics ----------------------------------------------------------------
local border = vim.g.lsp_round_borders_enabled and "rounded" or "none"
vim.diagnostic.config({
  virtual_text = (vim.g.diagnostics_mode or 3) >= 3,
  underline = (vim.g.diagnostics_mode or 3) >= 2,
  signs = (vim.g.diagnostics_mode or 3) >= 1,
  update_in_insert = false,
  float = { border = border },
})

-- ===========================================================================
-- Formatting (conform.nvim) — replaces none-ls formatting.
-- ===========================================================================
local conform = require("conform")
conform.setup({
  formatters_by_ft = {
    lua = { "stylua" },
    python = { "ruff_format" },
    javascript = { "prettierd" },
    typescript = { "prettierd" },
    javascriptreact = { "prettierd" },
    typescriptreact = { "prettierd" },
    json = { "prettierd" },
    jsonc = { "prettierd" },
    css = { "prettierd" },
    html = { "prettierd" },
    yaml = { "prettierd" },
    markdown = { "prettierd" },
    sh = { "shfmt" },
    bash = { "shfmt" },
  },
  formatters = {
    shfmt = { prepend_args = { "-i", "2" } }, -- matches your old none-ls shfmt config
  },
  -- Gated by your autoformat toggle (starts off, like your config).
  format_on_save = function(bufnr)
    local enabled = vim.b[bufnr].autoformat_enabled
    if enabled == nil then enabled = vim.g.autoformat_enabled end
    if not enabled then return end
    return { timeout_ms = 1500, lsp_format = "fallback" }
  end,
})

-- ===========================================================================
-- Linting (nvim-lint) — replaces none-ls diagnostics for tools without an LSP.
-- (ruff/eslint already run as LSP servers.)
-- ===========================================================================
local lint = require("lint")
lint.linters_by_ft = {
  sh = { "shellcheck" },
  bash = { "shellcheck" },
  yaml = { "yamllint" },
}
vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
  desc = "Run nvim-lint",
  callback = function() pcall(lint.try_lint) end,
})

-- ===========================================================================
-- LspAttach: buffer-local keymaps (ported from your 4-mappings.lua), codelens,
-- document highlight, inlay hints.
-- ===========================================================================
local has_telescope = function() return pcall(require, "telescope.builtin") end

vim.api.nvim_create_autocmd("LspAttach", {
  desc = "LSP buffer keymaps & features",
  callback = function(args)
    local bufnr = args.buf
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    local hover_opts = vim.g.lsp_round_borders_enabled and { border = "rounded" } or {}

    local function map(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc, silent = true })
    end
    local tb = function(name)
      return function() require("telescope.builtin")[name]() end
    end
    local ok_tel = has_telescope()

    -- Diagnostics
    map("n", "<leader>ld", vim.diagnostic.open_float, "Hover diagnostics")
    map("n", "gl", vim.diagnostic.open_float, "Hover diagnostics")
    map("n", "[d", function() vim.diagnostic.jump({ count = -1 }) end, "Previous diagnostic")
    map("n", "]d", function() vim.diagnostic.jump({ count = 1 }) end, "Next diagnostic")
    if ok_tel then map("n", "<leader>lD", tb("diagnostics"), "Diagnostics") end

    -- Info / restart
    map("n", "<leader>li", "<cmd>checkhealth vim.lsp<cr>", "LSP information")
    map("n", "<leader>lL", "<cmd>LspRestart<cr>", "LSP restart")

    -- Code action
    map({ "n", "v" }, "<leader>la", vim.lsp.buf.code_action, "LSP code action")

    -- Goto
    map("n", "gd", ok_tel and tb("lsp_definitions") or vim.lsp.buf.definition, "Goto definition")
    map("n", "gD", vim.lsp.buf.declaration, "Goto declaration")
    map("n", "gI", ok_tel and tb("lsp_implementations") or vim.lsp.buf.implementation, "Goto implementation")
    map("n", "gT", vim.lsp.buf.type_definition, "Goto type definition")
    map("n", "gr", ok_tel and tb("lsp_references") or vim.lsp.buf.references, "References")
    map("n", "<leader>lR", ok_tel and tb("lsp_references") or vim.lsp.buf.references, "References")

    -- Hover / signature / man
    map("n", "gh", function() vim.lsp.buf.hover(hover_opts) end, "Hover help")
    map("n", "gH", function() vim.lsp.buf.signature_help(hover_opts) end, "Signature help")
    map("n", "<leader>lh", function() vim.lsp.buf.hover(hover_opts) end, "Hover help")
    map("n", "<leader>lH", function() vim.lsp.buf.signature_help(hover_opts) end, "Signature help")
    map("n", "gm", "K", "Hover man")

    -- Rename
    map("n", "<leader>lr", vim.lsp.buf.rename, "Rename current symbol")

    -- Symbols
    map("n", "<leader>ls", function()
      if pcall(require, "aerial") then
        require("telescope").extensions.aerial.aerial()
      else
        require("telescope.builtin").lsp_document_symbols()
      end
    end, "Search symbol in buffer")
    map("n", "gs", function()
      if pcall(require, "aerial") then
        require("telescope").extensions.aerial.aerial()
      else
        require("telescope.builtin").lsp_document_symbols()
      end
    end, "Search symbol in buffer")
    map("n", "<leader>lS", vim.lsp.buf.workspace_symbol, "Search symbol in workspace")
    map("n", "gS", vim.lsp.buf.workspace_symbol, "Search symbol in workspace")

    -- Call hierarchy (replaces litee-calltree with native quickfix)
    map("n", "gj", vim.lsp.buf.incoming_calls, "Call tree (incoming)")
    map("n", "gJ", vim.lsp.buf.outgoing_calls, "Call tree (outgoing)")

    -- Formatting (conform)
    map({ "n", "v" }, "<leader>lf", function()
      require("conform").format({ async = true, lsp_format = "fallback" })
    end, "Format buffer")
    map("n", "<leader>uf", function() require("config.ui").toggle_buffer_autoformat() end, "Autoformat [b]")
    map("n", "<leader>uF", function() require("config.ui").toggle_autoformat() end, "Autoformat [g]")

    -- Inlay hints
    if vim.b.inlay_hints_enabled == nil then vim.b.inlay_hints_enabled = vim.g.inlay_hints_enabled end
    if vim.b.inlay_hints_enabled and client and client:supports_method("textDocument/inlayHint") then
      vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
    end
    map("n", "<leader>uH", function() require("config.ui").toggle_buffer_inlay_hints(bufnr) end, "Inlay hints [b]")

    -- Codelens
    if client and client:supports_method("textDocument/codeLens") then
      if vim.g.codelens_enabled then vim.lsp.codelens.refresh({ bufnr = bufnr }) end
      vim.api.nvim_create_autocmd({ "InsertLeave", "BufWritePost" }, {
        buffer = bufnr,
        callback = function()
          if vim.g.codelens_enabled then vim.lsp.codelens.refresh({ bufnr = bufnr }) end
        end,
      })
      map("n", "<leader>ll", function()
        vim.lsp.codelens.run()
        vim.lsp.codelens.refresh({ bufnr = bufnr })
      end, "LSP codelens run")
      map("n", "<leader>uL", function() require("config.ui").toggle_codelens() end, "Codelens [b]")
    end

    -- Document highlight on CursorHold
    if client and client:supports_method("textDocument/documentHighlight") then
      local grp = vim.api.nvim_create_augroup("lsp_doc_hl_" .. bufnr, { clear = true })
      vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
        group = grp, buffer = bufnr, callback = vim.lsp.buf.document_highlight,
      })
      vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "BufLeave" }, {
        group = grp, buffer = bufnr, callback = vim.lsp.buf.clear_references,
      })
    end

    -- :Format command
    vim.api.nvim_buf_create_user_command(bufnr, "Format", function()
      require("conform").format({ lsp_format = "fallback" })
    end, { desc = "Format file" })
  end,
})
