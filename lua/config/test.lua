-- ===========================================================================
-- Testing (neotest) — adapters trimmed to Python + Jest (your languages).
-- Coverage via nvim-coverage. Keymaps (<leader>T…) live in keymaps.lua.
-- ===========================================================================

require("neotest").setup({
  adapters = {
    require("neotest-python")({ dap = { justMyCode = false } }),
    require("neotest-jest")({}),
  },
})

require("coverage").setup({
  auto_reload = true,
  summary = { min_coverage = 80 },
})
