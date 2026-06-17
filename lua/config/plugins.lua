-- ===========================================================================
-- vim.pack plugin declarations + setup (replaces lazy.nvim).
--
-- vim.pack.add() clones missing plugins (first run) and loads them via :packadd
-- synchronously, so once the add() call returns everything is on the rtp. We
-- then call each plugin's setup(). There is no declarative lazy-loading like
-- lazy.nvim — the weight reduction comes from a leaner plugin list instead.
-- ===========================================================================

local data = vim.fn.stdpath("data")

local function plugin_path(name)
  -- Find a plugin's install dir regardless of vim.pack's pack-dir name.
  local hits = vim.fn.globpath(data .. "/site/pack", "*/opt/" .. name, false, true)
  return hits[1]
end

-- ---------------------------------------------------------------------------
-- Build / post-install hooks. MUST be registered BEFORE vim.pack.add().
-- ---------------------------------------------------------------------------
vim.api.nvim_create_autocmd("PackChanged", {
  desc = "Run build steps after a plugin is installed/updated",
  callback = function(ev)
    local spec = ev.data and ev.data.spec
    if not spec then return end
    local name, kind = spec.name, ev.data.kind
    if kind ~= "install" and kind ~= "update" then return end

    if name == "nvim-treesitter" then
      vim.schedule(function() pcall(vim.cmd, "TSUpdate") end)
    elseif name == "telescope-fzf-native.nvim" then
      local path = plugin_path(name)
      if path then
        vim.notify("Building telescope-fzf-native…", vim.log.levels.INFO)
        vim.system({ "make" }, { cwd = path }, function(out)
          if out.code ~= 0 then
            vim.schedule(function()
              vim.notify("fzf-native build failed:\n" .. (out.stderr or ""), vim.log.levels.WARN)
            end)
          end
        end)
      end
    elseif name == "markdown-preview.nvim" then
      vim.schedule(function() pcall(vim.fn["mkdp#util#install"]) end)
    end
  end,
})

-- ---------------------------------------------------------------------------
-- Plugin specs.  One batched add() so first-run installs clone in parallel.
-- ---------------------------------------------------------------------------
local function gh(repo) return "https://github.com/" .. repo end

vim.pack.add({
  -- Core libraries / consolidation -----------------------------------------
  gh("nvim-lua/plenary.nvim"),
  gh("MunifTanjim/nui.nvim"),
  gh("nvim-neotest/nvim-nio"),
  gh("kevinhwang91/promise-async"),
  -- mini.nvim gives us statusline, tabline, bufremove, indentscope, animate,
  -- icons, pairs and starter — one plugin replacing ~6.
  { src = gh("nvim-mini/mini.nvim"), version = "stable" },

  -- Treesitter (main branch — master crashes on Neovim 0.12's query API) ----
  { src = gh("nvim-treesitter/nvim-treesitter"), version = "main" },
  { src = gh("nvim-treesitter/nvim-treesitter-textobjects"), version = "main" },

  -- LSP / completion / format / lint ---------------------------------------
  gh("neovim/nvim-lspconfig"),
  gh("mason-org/mason.nvim"),
  gh("folke/lazydev.nvim"),
  { src = gh("saghen/blink.cmp"), version = vim.version.range("1") },
  gh("rafamadriz/friendly-snippets"),
  gh("stevearc/conform.nvim"),
  gh("mfussenegger/nvim-lint"),
  gh("ray-x/lsp_signature.nvim"),
  gh("kosayoda/nvim-lightbulb"),

  -- Finder / project --------------------------------------------------------
  gh("nvim-telescope/telescope.nvim"),
  { src = gh("nvim-telescope/telescope-fzf-native.nvim") },
  gh("debugloop/telescope-undo.nvim"),
  gh("AckslD/nvim-neoclip.lua"),
  gh("ahmedkhalf/project.nvim"),
  gh("nvim-pack/nvim-spectre"),

  -- Git ---------------------------------------------------------------------
  gh("lewis6991/gitsigns.nvim"),
  gh("tpope/vim-fugitive"),
  gh("tpope/vim-rhubarb"),

  -- File browsing / navigation ---------------------------------------------
  gh("nvim-neo-tree/neo-tree.nvim"),
  gh("mikavilpas/yazi.nvim"),
  gh("stevearc/aerial.nvim"),
  gh("smoka7/hop.nvim"),
  gh("mrjones2014/smart-splits.nvim"),
  gh("akinsho/toggleterm.nvim"),

  -- Editing utilities -------------------------------------------------------
  gh("kevinhwang91/nvim-ufo"),
  gh("NMAC427/guess-indent.nvim"),
  gh("andymass/vim-matchup"),
  gh("cappyzawa/trim.nvim"),
  gh("stevearc/stickybuf.nvim"),
  gh("folke/zen-mode.nvim"),
  gh("folke/todo-comments.nvim"),
  gh("lambdalisue/vim-suda"),
  gh("Shatur/neovim-session-manager"),
  gh("folke/which-key.nvim"),
  gh("stevearc/dressing.nvim"),
  gh("brenoprata10/nvim-highlight-colors"),

  -- Notifications / UI niceties --------------------------------------------
  gh("rcarriga/nvim-notify"),
  gh("folke/noice.nvim"),
  gh("petertriho/nvim-scrollbar"),
  gh("Eandrju/cellular-automaton.nvim"),
  gh("nvzone/volt"),         -- UI lib (dep for wrapped.nvim)
  gh("aikhe/wrapped.nvim"),  -- "year in review" stats for your nvim config
  gh("Amansingh-afk/milli.nvim"), -- animated ASCII splash in mini.starter

  -- Markdown ----------------------------------------------------------------
  gh("MeanderingProgrammer/render-markdown.nvim"),
  gh("bngarren/checkmate.nvim"),
  gh("iamcco/markdown-preview.nvim"),

  -- Debug (DAP) -------------------------------------------------------------
  gh("mfussenegger/nvim-dap"),
  gh("rcarriga/nvim-dap-ui"),
  gh("jbyuki/one-small-step-for-vimkind"),

  -- Test --------------------------------------------------------------------
  gh("nvim-neotest/neotest"),
  gh("nvim-neotest/neotest-python"),
  gh("nvim-neotest/neotest-jest"),
  gh("andythigpen/nvim-coverage"),

  -- BQN ---------------------------------------------------------------------
  gh("mlochbaum/BQN"),
  gh("calebowens/nvim-bqn"),

  -- Colorschemes (active: posterpole; cycle/preview them all with <leader>ft) -
  gh("psynyde/mono"),
  gh("eldritch-theme/eldritch.nvim"),
  gh("ilof2/posterpole.nvim"),
  gh("yorumicolors/yorumi.nvim"),
  gh("rileytwo/kiss"),
})

-- ===========================================================================
-- Setup (order: icons first so other UIs pick them up).
-- ===========================================================================

-- mini.icons + devicons shim --------------------------------------------------
require("mini.icons").setup()
MiniIcons.mock_nvim_web_devicons()

-- Statusline / tabline --------------------------------------------------------
require("mini.statusline").setup({ use_icons = true })
require("mini.tabline").setup()

-- Buffer removal / indent guides / animations --------------------------------
require("mini.bufremove").setup()
require("mini.indentscope").setup({
  draw = { delay = 50 },
  symbol = "│",
  options = { try_as_border = true },
})
require("mini.animate").setup({
  scroll = { enable = false }, -- scroll animation fights scrolloff=1000; keep cursor/resize only.
})
-- mini.pairs honours vim.g.minipairs_disable; start matching your autopairs_enabled.
vim.g.minipairs_disable = not vim.g.autopairs_enabled
require("mini.pairs").setup()

-- Greeter (mini.starter, replaces alpha-nvim) --------------------------------
local starter = require("mini.starter")

-- Header: animated sysyphus splash via milli.nvim once the gif is converted to
-- frames (lua/milli/splashes/sysyphus.lua — see assets/README.md). Until then,
-- fall back to the AESV banner. milli.starter() animates the splash in place,
-- anchoring on its first frame, which we seed as the header.
local header = table.concat({
  "",
  " █████╗ ███████╗███████╗██╗   ██╗",
  "██╔══██╗██╔════╝██╔════╝██║   ██║",
  "███████║█████╗  ███████╗██║   ██║",
  "██╔══██║██╔══╝  ╚════██║╚██╗ ██╔╝",
  "██║  ██║███████╗███████║ ╚████╔╝ ",
  "╚═╝  ╚═╝╚══════╝╚══════╝  ╚═══╝  ",
  "",
  os.date("%A %d %B %Y"),
  "",
}, "\n")
do
  local ok, milli = pcall(require, "milli")
  if ok then
    local loaded, data = pcall(milli.load, { splash = "sysyphus" })
    if loaded and data and data.frames and data.frames[1] then
      header = table.concat(data.frames[1], "\n")
      milli.starter({ splash = "sysyphus", loop = true })
    end
  end
end

starter.setup({
  header = header,
  items = {
    starter.sections.recent_files(6, false), -- recent in cwd
    {
      { name = "Find file", action = "Telescope find_files", section = "Actions" },
      { name = "Find word", action = "Telescope live_grep", section = "Actions" },
      { name = "New file", action = "enew", section = "Actions" },
      {
        name = "Config",
        action = "lua require('telescope.builtin').find_files({cwd=vim.fn.stdpath('config'),follow=true})",
        section = "Actions",
      },
      { name = "Sessions", action = "SessionManager! load_session", section = "Actions" },
      { name = "Update plugins", action = "PackUpdate", section = "Actions" },
      { name = "Quit", action = "qa", section = "Actions" },
    },
  },
  content_hooks = {
    starter.gen_hook.adding_bullet(),
    starter.gen_hook.aligning("center", "center"),
  },
  footer = "vade, vide, vince.",
})

-- Treesitter (main branch) ----------------------------------------------------
-- Main branch doesn't auto-enable highlighting or take an ensure_installed list:
-- we install() parsers and start highlighting per-buffer in a FileType autocmd.
local ts_parsers = {
  "lua", "vim", "vimdoc", "query",
  "python", "javascript", "typescript", "tsx", "html", "css",
  "json", "yaml", "toml", "bash",
  "markdown", "markdown_inline",
  "diff", "git_config", "gitcommit", "gitignore", "regex",
}
pcall(function() require("nvim-treesitter").install(ts_parsers) end)

vim.api.nvim_create_autocmd("FileType", {
  desc = "Start treesitter highlighting",
  callback = function(ev)
    local big = vim.g.big_file or { size = 1024 * 5000 }
    local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(ev.buf))
    if ok and stats and stats.size > big.size then return end
    pcall(vim.treesitter.start, ev.buf)
  end,
})

-- Treesitter textobjects (main-branch API: setup + manual maps) ---------------
pcall(function()
  require("nvim-treesitter-textobjects").setup({
    select = { lookahead = true },
    move = { set_jumps = true },
  })
  local sel = require("nvim-treesitter-textobjects.select").select_textobject
  local move = require("nvim-treesitter-textobjects.move")
  for _, t in ipairs({ { "f", "@function" }, { "c", "@class" }, { "a", "@parameter" } }) do
    local key, q = t[1], t[2]
    vim.keymap.set({ "x", "o" }, "a" .. key, function() sel(q .. ".outer", "textobjects") end, { desc = "around " .. q })
    vim.keymap.set({ "x", "o" }, "i" .. key, function() sel(q .. ".inner", "textobjects") end, { desc = "inside " .. q })
  end
  vim.keymap.set({ "n", "x", "o" }, "]f", function() move.goto_next_start("@function.outer", "textobjects") end, { desc = "Next function" })
  vim.keymap.set({ "n", "x", "o" }, "[f", function() move.goto_previous_start("@function.outer", "textobjects") end, { desc = "Prev function" })
  vim.keymap.set({ "n", "x", "o" }, "]c", function() move.goto_next_start("@class.outer", "textobjects") end, { desc = "Next class" })
  vim.keymap.set({ "n", "x", "o" }, "[c", function() move.goto_previous_start("@class.outer", "textobjects") end, { desc = "Prev class" })
end)

-- Completion (blink.cmp) ------------------------------------------------------
require("blink.cmp").setup({
  keymap = {
    preset = "enter", -- Enter accepts, C-n/C-p navigate, C-space toggles.
    ["<Tab>"] = { "select_next", "fallback" },
    ["<S-Tab>"] = { "select_prev", "fallback" },
  },
  appearance = { nerd_font_variant = "mono" },
  sources = { default = { "lsp", "path", "snippets", "buffer" } },
  completion = {
    documentation = { auto_show = true, auto_show_delay_ms = 150 },
    menu = { border = "rounded" },
  },
  signature = { enabled = false }, -- lsp_signature.nvim handles this.
  fuzzy = { implementation = "prefer_rust_with_warning" },
  enabled = function()
    return vim.g.cmp_enabled ~= false and vim.bo.buftype ~= "prompt"
  end,
})

-- LSP-ish UI helpers ----------------------------------------------------------
require("lazydev").setup({
  library = { { path = "${3rd}/luv/library", words = { "vim%.uv" } } },
})
-- lsp_signature / lightbulb / highlight-colors are set up in the deferred block.

-- Finder ----------------------------------------------------------------------
local telescope = require("telescope")
telescope.setup({
  defaults = {
    prompt_prefix = "  ",
    selection_caret = " ",
    path_display = { "truncate" },
    mappings = {
      i = {
        ["<C-j>"] = "move_selection_next",
        ["<C-k>"] = "move_selection_previous",
        ["<esc>"] = "close",
      },
    },
  },
  extensions = {
    fzf = { fuzzy = true, override_generic_sorter = true, override_file_sorter = true },
  },
})
-- project.nvim must be set up synchronously: its autocmd has to be registered
-- before the startup file's BufEnter so it can set cwd to the project root.
-- pattern-only detection: finds the git/Makefile/etc. root, and avoids the
-- "lsp" method's deprecated vim.lsp.buf_get_clients() call (0.12 warning).
require("project_nvim").setup({
  manual_mode = false,
  detection_methods = { "pattern" },
})

-- Session manager — MUST be synchronous (before VimEnter) so autoload is
-- Disabled in time. Otherwise it autoloads the last session on startup and
-- opens the previous file instead of the greeter. Manual load via <leader>S….
do
  local ok, sm = pcall(require, "session_manager")
  if ok then
    sm.setup({
      autoload_mode = require("session_manager.config").AutoloadMode.Disabled,
      autosave_last_session = true,
    })
  end
end
-- telescope extensions, neoclip, spectre load in the deferred block at the
-- bottom (not needed for the first paint).

-- Git -------------------------------------------------------------------------
require("gitsigns").setup({
  max_file_length = 40000,
  signs = {
    add = { text = "▎" },
    change = { text = "▎" },
    delete = { text = "" },
    topdelete = { text = "" },
    changedelete = { text = "▎" },
    untracked = { text = "▎" },
  },
})
vim.g.fugitive_no_maps = 1

-- File browsing / navigation --------------------------------------------------
require("neo-tree").setup({
  close_if_last_window = true,
  filesystem = {
    follow_current_file = { enabled = true },
    use_libuv_file_watcher = true,
    hijack_netrw_behavior = "open_default",
  },
})
require("yazi").setup({ open_for_directories = false })
require("aerial").setup({
  attach_mode = "global",
  backends = { "lsp", "treesitter", "markdown", "man" },
  layout = { min_width = 28 },
})
require("hop").setup()
require("smart-splits").setup()
require("toggleterm").setup({
  size = 10,
  open_mapping = nil, -- mapped explicitly in keymaps.lua
  direction = "float",
  float_opts = { border = "curved" },
  shade_terminals = true,
})

-- Editing utilities -----------------------------------------------------------
-- nvim-ufo is set up in the deferred block (folds engage on first BufRead).
require("guess-indent").setup()
require("trim").setup({ trim_on_write = true, trim_last_line = false, trim_first_line = false })
require("stickybuf").setup()
require("zen-mode").setup()
require("todo-comments").setup()
require("dressing").setup()
-- vim-matchup: disable its own offscreen popup, let treesitter integration drive it.
vim.g.matchup_matchparen_offscreen = { method = "popup" }

-- Notifications / UI ----------------------------------------------------------
local notify = require("notify")
notify.setup({ timeout = 3000, fps = 30, render = "compact", stages = "fade" })
vim.notify = notify
require("noice").setup({
  cmdline = { enabled = true, view = "cmdline_popup" },
  messages = { enabled = true, view = "mini" },
  lsp = {
    progress = { enabled = false },
    hover = { enabled = false },
    signature = { enabled = false },
  },
  presets = { bottom_search = true, command_palette = true, long_message_to_split = true },
})
-- nvim-scrollbar is set up in the deferred block.

-- Markdown --------------------------------------------------------------------
require("render-markdown").setup({ completions = { lsp = { enabled = true } } })
require("checkmate").setup()
vim.g.mkdp_filetypes = { "markdown" }

-- which-key group labels ------------------------------------------------------
local wk = require("which-key")
wk.setup({ preset = "modern" })
wk.add({
  { "<leader>f", group = " Find" },
  { "<leader>g", group = " Git" },
  { "<leader>l", group = " LSP" },
  { "<leader>u", group = " UI toggles" },
  { "<leader>b", group = " Buffers" },
  { "<leader>d", group = " Debugger" },
  { "<leader>T", group = " Test" },
  { "<leader>D", group = " Docs" },
  { "<leader>S", group = " Session" },
  { "<leader>t", group = " Terminal" },
  { "<leader>p", group = " Packages" },
  { "<leader>B", group = "⊢ BQN" },
})

-- Colorscheme (synchronous — needed for the first paint) ----------------------
pcall(function() require("posterpole").setup({}) end)
if not pcall(vim.cmd.colorscheme, vim.g.default_colorscheme) then
  vim.notify("Could not load colorscheme: " .. tostring(vim.g.default_colorscheme), vim.log.levels.WARN)
end

-- ---------------------------------------------------------------------------
-- Deferred setup: everything not needed for the first paint runs the instant
-- Neovim goes idle (next event-loop tick, before any user input can land).
-- This is what keeps startup buttery without per-plugin lazy-loading config.
-- ---------------------------------------------------------------------------
vim.schedule(function()
  -- Folding (engages on the first BufRead, a tick after open)
  require("ufo").setup({
    provider_selector = function() return { "treesitter", "indent" } end,
  })

  -- Telescope extensions + project tracking + neoclip + spectre
  pcall(telescope.load_extension, "fzf") -- only if the native build succeeded
  pcall(telescope.load_extension, "undo")
  pcall(telescope.load_extension, "neoclip")
  require("neoclip").setup()
  pcall(telescope.load_extension, "projects")
  require("spectre").setup()

  -- LSP eye-candy
  require("lsp_signature").setup({ hint_enable = false, floating_window = false })
  require("nvim-lightbulb").setup({
    autocmd = { enabled = true },
    sign = { enabled = false },
    virtual_text = { enabled = true, text = "💡" },
  })
  require("nvim-highlight-colors").setup({ enable_named_colors = true, render = "background" })

  -- Scrollbar (+ gitsigns integration)
  require("scrollbar").setup({ excluded_filetypes = { "neo-tree", "alpha", "starter" } })
  pcall(function() require("scrollbar.handlers.gitsigns").setup() end)

  -- wrapped.nvim — :WrappedNvim for config stats/heatmap (also <leader>pw)
  pcall(function() require("wrapped").setup({ path = vim.fn.stdpath("config") }) end)
end)
