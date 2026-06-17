-- ===========================================================================
-- Debugging (nvim-dap + dap-ui).  Adapters trimmed to your languages:
-- Python (debugpy), Lua (one-small-step-for-vimkind). Node stub included.
-- Keymaps (F5/F9/F10/F11, <leader>d…) live in keymaps.lua.
-- ===========================================================================

local dap = require("dap")
local dapui = require("dapui")

dapui.setup({ floating = { border = "rounded" } })

-- Auto open/close the UI.
dap.listeners.after.event_initialized["dapui"] = function() dapui.open() end
dap.listeners.before.event_terminated["dapui"] = function() dapui.close() end
dap.listeners.before.event_exited["dapui"] = function() dapui.close() end

-- Breakpoint signs.
vim.fn.sign_define("DapBreakpoint", { text = "", texthl = "DiagnosticError" })
vim.fn.sign_define("DapStopped", { text = "", texthl = "DiagnosticWarn" })

-- Python (debugpy installed via Mason) -------------------------------------
local mason = vim.fn.stdpath("data") .. "/mason"
local debugpy_python = mason .. "/packages/debugpy/venv/bin/python"
dap.adapters.python = {
  type = "executable",
  command = (vim.uv.fs_stat(debugpy_python) and debugpy_python) or "python3",
  args = { "-m", "debugpy.adapter" },
}
dap.configurations.python = {
  {
    type = "python",
    request = "launch",
    name = "Launch file",
    program = "${file}",
    pythonPath = function()
      return (vim.fn.executable(".venv/bin/python") == 1 and ".venv/bin/python") or "python3"
    end,
  },
}

-- Lua (debug Neovim itself via osv) ----------------------------------------
dap.configurations.lua = {
  { type = "nlua", request = "attach", name = "Attach to running Neovim instance" },
}
dap.adapters.nlua = function(callback, config)
  callback({ type = "server", host = config.host or "127.0.0.1", port = config.port or 8086 })
end

-- Node / JS (requires js-debug-adapter via :MasonInstall js-debug-adapter) --
local js_debug = mason .. "/packages/js-debug-adapter/js-debug-adapter"
if vim.uv.fs_stat(js_debug) then
  dap.adapters["pwa-node"] = {
    type = "server",
    host = "localhost",
    port = "${port}",
    executable = { command = js_debug, args = { "${port}" } },
  }
  for _, ft in ipairs({ "javascript", "typescript" }) do
    dap.configurations[ft] = {
      { type = "pwa-node", request = "launch", name = "Launch file", program = "${file}", cwd = "${workspaceFolder}" },
    }
  end
end
