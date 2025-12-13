# nvim-config

My personal Neovim configuration, forked from [NormalNvim](https://github.com/NormalNvim/NormalNvim).

## Overview

This is a batteries-included Neovim setup optimized for macOS terminal development. Part of my [dotfiles](https://github.com/4esv/dotfiles).

## Features

- **Lazy loading** - Fast startup with plugins loaded on-demand
- **LSP & Treesitter** - Full IDE features out of the box
- **Compiler & Debugger** - Built-in support via Compiler.nvim and DAP
- **Theme** - Bluloco colorscheme

## Installation

This config is managed as a submodule of my dotfiles:

```bash
# Full dotfiles setup (recommended)
git clone --recurse-submodules https://github.com/4esv/dotfiles.git ~/dotfiles
~/dotfiles/bin/.local/bin/dots install

# Or standalone
git clone https://github.com/4esv/nvim-config.git ~/.config/nvim
```

## Requirements

- Neovim 0.11+
- A [Nerd Font](https://www.nerdfonts.com/)
- Node.js (for LSP servers)
- ripgrep, fd (for telescope)

## Upstream

Based on [NormalNvim](https://github.com/NormalNvim/NormalNvim) - check their wiki for detailed documentation on keybindings and customization.

## License

MIT
