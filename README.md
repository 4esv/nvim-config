# nvim-config

Personal Neovim config — **Neovim 0.12+**, built on the native **`vim.pack`**
plugin manager (no lazy.nvim). Slimmed from a NormalNvim fork: ~122 plugins → ~60,
with the same daily keybindings and workflow.

> Requires Neovim **0.12+** (for `vim.pack`). On older Neovim it won't start.

## Layout

```
init.lua            entry: leader, built-in disables, module load order
lua/config/
  options.lua       vim.opt + toggle globals + filetypes
  plugins.lua       vim.pack.add (all plugins) + setups + deferred block
  lsp.lua           mason install + native vim.lsp.enable + conform + nvim-lint
  debug.lua         nvim-dap + dap-ui (deferred)
  test.lua          neotest + coverage (deferred)
  keymaps.lua       all keybindings (LSP maps live in lsp.lua on LspAttach)
  autocmds.lua      autocmds + user commands
  ui.lua            <leader>u… toggle helpers
after/ftplugin/bqn.lua   BQN buffer setup + inline-eval maps
ftdetect/bqn.lua         .bqn filetype
```

## Stack

- **Plugins:** `vim.pack` — `:PackUpdate` to update, `:PackStatus` to inspect.
- **Completion:** blink.cmp (Enter accepts, Tab/S-Tab navigate, C-space toggles).
- **UI:** mini.statusline + mini.tabline + mini.starter; mini.icons/pairs/
  indentscope/animate. Theme: **eldritch** (swap live with `<leader>ft`; `mono`
  is bundled but monochrome by design).
- **LSP:** native `vim.lsp.enable`, servers installed via Mason on first launch
  (basedpyright, ruff, lua_ls, ts_ls, html/css/json/yaml/bash).
- **Format/lint:** conform.nvim (`<leader>lf`, autoformat toggle `<leader>uf/uF`)
  + nvim-lint (shellcheck, yamllint).
- **Finder:** telescope (+fzf-native, undo, neoclip). **Git:** gitsigns + fugitive.
- **Languages tooled:** Python, Lua, JS/TS + web, shell, YAML, BQN. DAP + neotest
  trimmed to those.

## Performance

Startup ~95ms warm. Everything not needed for the first paint (telescope
extensions, ufo, dap, neotest, mason install, eye-candy) runs in a `vim.schedule`
block that fires the instant Neovim goes idle — before any input lands.

## Keymaps

`<space>` leader, `,` localleader. Press `<space>` and wait for the full
which-key menu (every mapping is labeled). Groups: `f` find · `g` git · `l` lsp ·
`u` ui toggles · `b` buffers · `d` debug · `T` test · `D` docs · `S` session ·
`t` terminal · `p` packages · `B` BQN.

## Requirements

- Neovim 0.12+
- [Nerd Font](https://www.nerdfonts.com/)
- Node.js, ripgrep, fd, a C compiler (treesitter), and optionally yazi/lazygit

## History

`main` holds the previous lazy.nvim / NormalNvim-fork config (0.11). This branch
(`vim-pack`) is the 0.12 native-pack rewrite.

## License

MIT
