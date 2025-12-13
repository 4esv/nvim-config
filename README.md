# nvim-config

My personal Neovim configuration, forked from [NormalNvim](https://github.com/NormalNvim/NormalNvim).

## What's Different

### Theme
- **Colorscheme**: `eldritch` instead of Tokyo Night

### Additional Plugins

| Plugin | Purpose |
|--------|---------|
| `render-markdown.nvim` | Render markdown in normal mode |
| `checkmate.nvim` | Toggle markdown checkboxes |
| `nvim-highlight-colors` | Visualize hex colors inline |
| `neotest` | Testing framework (10+ language adapters) |
| `nvim-coverage` | Code coverage visualization |

### Keybinding Highlights

```
<leader>w     Save file
<leader>W     Save as sudo
<leader>q     Quit with confirmation
|             Vertical split
\             Horizontal split
<C-y/d/p>     Clipboard operations
x/X           Delete without yanking
```

Plus ~1600 lines of custom mappings for LSP, DAP, Telescope, testing, etc.

### Default Toggles Changed

```lua
vim.g.autopairs_enabled = false
vim.g.autoformat_enabled = false
vim.g.inlay_hints_enabled = false
```

### LSP & Formatting

Custom null-ls sources configured:
- **Diagnostics**: cpplint, eslint, flake8, luacheck, yamllint
- **Formatting**: autopep8, beautysh, eslint, jq, rustfmt, shfmt (2-space indent)

## Installation

Part of my [dotfiles](https://github.com/4esv/dotfiles):

```bash
git clone --recurse-submodules https://github.com/4esv/dotfiles.git ~/dotfiles
~/dotfiles/bin/.local/bin/dots install
```

Or standalone:

```bash
git clone https://github.com/4esv/nvim-config.git ~/.config/nvim
```

## Requirements

- Neovim 0.11+
- [Nerd Font](https://www.nerdfonts.com/)
- Node.js, ripgrep, fd

## Upstream

Based on [NormalNvim](https://github.com/NormalNvim/NormalNvim) - see their [wiki](https://github.com/NormalNvim/NormalNvim/wiki) for base documentation.

## License

MIT
