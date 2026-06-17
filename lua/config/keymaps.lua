-- ===========================================================================
-- Keymaps ported from your NormalNvim 4-mappings.lua. LSP buffer-local maps
-- live in config/lsp.lua (LspAttach). Buffer management is reimplemented on
-- mini.bufremove (heirline-components is gone).
-- ===========================================================================

local map = vim.keymap.set
local ui = require("config.ui")
local function has(mod) return pcall(require, mod) end

-- ---------------------------------------------------------------------------
-- Standard operations
-- ---------------------------------------------------------------------------
map("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, desc = "Move cursor down" })
map("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, desc = "Move cursor up" })
map("n", "<leader>w", "<cmd>w<cr>", { desc = "Save" })
map("n", "<leader>W", "<cmd>SudaWrite<cr>", { desc = "Save as sudo" })
map("n", "<leader>n", "<cmd>enew<cr>", { desc = "New file" })
map("n", "<leader>/", "gcc", { remap = true, desc = "Toggle comment line" })
map("x", "<leader>/", "gc", { remap = true, desc = "Toggle comment" })
map("n", "gx", function()
  vim.ui.open(vim.fn.expand("<cfile>"))
end, { desc = "Open the file under cursor with a program" })
map("n", "<C-s>", "<cmd>w!<cr>", { desc = "Force write" })
map("n", "|", "<cmd>vsplit<cr>", { desc = "Vertical Split" })
map("n", "\\", "<cmd>split<cr>", { desc = "Horizontal Split" })
map("i", "<C-BS>", "<C-W>", { desc = "CTRL+backspace to delete word" })
map("n", "0", "^", { desc = "Go to first character of the line" })
map("n", "<leader>q", function()
  local choice = vim.fn.confirm("Do you really want to exit nvim?", "&Yes\n&No", 2)
  if choice == 1 then vim.cmd("confirm quit") end
end, { desc = "Quit" })
map("n", "<Tab>", "<Tab>", { noremap = true, silent = true, desc = "Prevent TAB from acting as <C-i>" })

-- ---------------------------------------------------------------------------
-- Clipboard
-- ---------------------------------------------------------------------------
map({ "n", "x" }, "<C-y>", '"+y<esc>', { desc = "Copy to clipboard" })
map({ "n", "x" }, "<C-d>", '"+y<esc>dd', { desc = "Copy to clipboard and delete line" })
map("n", "<C-p>", '"+p<esc>', { desc = "Paste from clipboard" })

map({ "n", "x" }, "c", '"_c', { desc = "Change without yanking" })
map({ "n", "x" }, "C", '"_C', { desc = "Change without yanking" })

local function smart_x(key)
  return function()
    if vim.fn.col(".") == 1 then
      local line = vim.fn.getline(".")
      if line:match("^%s*$") then
        vim.api.nvim_feedkeys('"_dd', "n", false)
        vim.api.nvim_feedkeys("$", "n", false)
        return
      end
    end
    vim.api.nvim_feedkeys('"_' .. key, "n", false)
  end
end
map("n", "x", smart_x("x"), { desc = "Delete character without yanking" })
map("n", "X", smart_x("X"), { desc = "Delete before character without yanking" })
map("x", "x", '"_x', { desc = "Delete without yanking" })
map("x", "X", '"_X', { desc = "Delete without yanking" })
map("x", "p", "P", { desc = "Paste without yanking selection" })
map("x", "P", "p", { desc = "Yank then paste" })

-- ---------------------------------------------------------------------------
-- Search highlight: ESC clears, otherwise normal ESC
-- ---------------------------------------------------------------------------
map("n", "<ESC>", function()
  if vim.v.hlsearch == 1 then
    vim.cmd("nohlsearch")
  else
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<ESC>", true, true, true), "n", true)
  end
end)

-- ---------------------------------------------------------------------------
-- Improved tabulation
-- ---------------------------------------------------------------------------
map("x", "<S-Tab>", "<gv", { desc = "unindent line" })
map("x", "<Tab>", ">gv", { desc = "indent line" })
map("x", "<", "<gv", { desc = "unindent line" })
map("x", ">", ">gv", { desc = "indent line" })

-- ---------------------------------------------------------------------------
-- Improved gg / G / select-all
-- ---------------------------------------------------------------------------
local function no_anim(fn)
  return function()
    vim.g.minianimate_disable = true
    fn()
    vim.g.minianimate_disable = false
  end
end
map({ "n", "x" }, "gg", no_anim(function()
  if vim.v.count > 0 then vim.cmd("normal! " .. vim.v.count .. "gg") else vim.cmd("normal! gg0") end
end), { desc = "gg and go to the first position" })
map({ "n", "x" }, "G", no_anim(function() vim.cmd("normal! G$") end), { desc = "G and go to the last position" })
map("n", "<C-a>", no_anim(function() vim.cmd("normal! gg0vG$") end), { desc = "Visually select all" })

-- ---------------------------------------------------------------------------
-- Packages (vim.pack / mason / treesitter)
-- ---------------------------------------------------------------------------
map("n", "<leader>pu", function() vim.pack.update() end, { desc = "Update plugins (review)" })
map("n", "<leader>pU", function() vim.pack.update(nil, { force = true }) end, { desc = "Update plugins (force)" })
map("n", "<leader>pm", "<cmd>Mason<cr>", { desc = "Mason open" })
map("n", "<leader>pM", "<cmd>MasonUpdate<cr>", { desc = "Mason registry update" })
map("n", "<leader>pT", "<cmd>TSUpdate<cr>", { desc = "Treesitter update" })
map("n", "<leader>pw", "<cmd>WrappedNvim<cr>", { desc = "Nvim Wrapped (config stats)" })

-- ---------------------------------------------------------------------------
-- Buffers / tabs (reimplemented on mini.bufremove + native cmds)
-- ---------------------------------------------------------------------------
local function bufremove() return require("mini.bufremove") end
local function listed_bufs()
  return vim.tbl_filter(function(b) return vim.bo[b].buflisted end, vim.api.nvim_list_bufs())
end

map("n", "<leader>c", function() bufremove().wipeout() end, { desc = "Wipe buffer" })
map("n", "<leader>C", function() bufremove().delete() end, { desc = "Close buffer" })
map("n", "<leader>bw", "<cmd>silent! close<cr>", { desc = "Close window" })
map("n", "<leader>ba", "<cmd>wa<cr>", { desc = "Write all changed buffers" })
map("n", "]b", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "[b", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
map("n", "]t", function() vim.cmd.tabnext() end, { desc = "Next tab" })
map("n", "[t", function() vim.cmd.tabprevious() end, { desc = "Previous tab" })

map("n", "<leader>bc", function()
  local cur = vim.api.nvim_get_current_buf()
  for _, b in ipairs(listed_bufs()) do
    if b ~= cur then pcall(function() bufremove().delete(b) end) end
  end
end, { desc = "Close all buffers except current" })
map("n", "<leader>bC", function()
  for _, b in ipairs(listed_bufs()) do pcall(function() bufremove().delete(b) end) end
end, { desc = "Close all buffers" })
map("n", "<leader>bb", function() require("telescope.builtin").buffers() end, { desc = "Select buffer" })

-- ---------------------------------------------------------------------------
-- UI toggles  [<leader>u]
-- ---------------------------------------------------------------------------
map("n", "<leader>uz", ui.toggle_zen_mode, { desc = "Zen mode" })
map("n", "<leader>ua", ui.toggle_autopairs, { desc = "Autopairs" })
map("n", "<leader>ub", ui.toggle_background, { desc = "Background" })
map("n", "<leader>uc", ui.toggle_cmp, { desc = "Autocompletion" })
map("n", "<leader>uC", ui.toggle_css_colors, { desc = "CSS #colors" })
map("n", "<leader>ud", ui.toggle_diagnostics, { desc = "LSP Diagnostics" })
map("n", "<leader>ug", ui.toggle_signcolumn, { desc = "Signcolumn" })
map("n", "<leader>ul", ui.toggle_statusline, { desc = "Statusline" })
map("n", "<leader>un", ui.toggle_line_numbers, { desc = "Line numbers" })
map("n", "<leader>uN", ui.toggle_notifications, { desc = "Notifications" })
map("n", "<leader>uP", ui.toggle_paste, { desc = "Paste mode" })
map("n", "<leader>us", ui.toggle_spell, { desc = "Spellcheck" })
map("n", "<leader>uS", ui.toggle_conceal, { desc = "Conceal" })
map("n", "<leader>ut", ui.toggle_tabline, { desc = "Tabline" })
map("n", "<leader>uT", ui.set_tabulation, { desc = "Tabulation" })
map("n", "<leader>uu", ui.toggle_url_hl, { desc = "URL highlight" })
map("n", "<leader>uw", ui.toggle_wrap, { desc = "Line wrap" })
map("n", "<leader>uy", ui.toggle_buffer_syntax, { desc = "Syntax highlight" })
map("n", "<leader>uh", ui.toggle_foldcolumn, { desc = "Foldcolumn" })
map("n", "<leader>up", ui.toggle_lsp_signature, { desc = "LSP signature" })
map("n", "<leader>uA", ui.toggle_animations, { desc = "Animations" })

-- ---------------------------------------------------------------------------
-- Shifted movement
-- ---------------------------------------------------------------------------
map("n", "<S-Down>", function() vim.api.nvim_feedkeys("7j", "n", true) end, { desc = "Fast move down" })
map("n", "<S-Up>", function() vim.api.nvim_feedkeys("7k", "n", true) end, { desc = "Fast move up" })
map("n", "<S-PageDown>", function()
  local cur, total = vim.fn.line("."), vim.fn.line("$")
  local target = math.min(cur + 1 + math.floor(total * 0.20), total)
  vim.api.nvim_win_set_cursor(0, { target, 0 })
  vim.cmd("normal! zz")
end, { desc = "Page down 20%" })
map("n", "<S-PageUp>", function()
  local target = math.max(vim.fn.line(".") - 1 - math.floor(vim.fn.line("$") * 0.20), 1)
  vim.api.nvim_win_set_cursor(0, { target, 0 })
  vim.cmd("normal! zz")
end, { desc = "Page up 20%" })

-- ---------------------------------------------------------------------------
-- Greeter (mini.starter, replaces alpha)
-- ---------------------------------------------------------------------------
map("n", "<leader>h", function() require("mini.starter").open() end, { desc = "Home screen" })

-- ---------------------------------------------------------------------------
-- Git  [<leader>g]
-- ---------------------------------------------------------------------------
map("n", "]g", function() require("gitsigns").nav_hunk("next") end, { desc = "Next Git hunk" })
map("n", "[g", function() require("gitsigns").nav_hunk("prev") end, { desc = "Previous Git hunk" })
map("n", "<leader>gl", function() require("gitsigns").blame_line() end, { desc = "View Git blame" })
map("n", "<leader>gL", function() require("gitsigns").blame_line({ full = true }) end, { desc = "Full Git blame" })
map("n", "<leader>gp", function() require("gitsigns").preview_hunk() end, { desc = "Preview Git hunk" })
map("n", "<leader>gh", function() require("gitsigns").reset_hunk() end, { desc = "Reset Git hunk" })
map("n", "<leader>gr", function() require("gitsigns").reset_buffer() end, { desc = "Reset Git buffer" })
map("n", "<leader>gs", function() require("gitsigns").stage_hunk() end, { desc = "Stage Git hunk" })
map("n", "<leader>gS", function() require("gitsigns").stage_buffer() end, { desc = "Stage Git buffer" })
map("n", "<leader>gu", function() require("gitsigns").undo_stage_hunk() end, { desc = "Unstage Git hunk" })
map("n", "<leader>gd", function() require("gitsigns").diffthis() end, { desc = "View Git diff" })
map("n", "<leader>gP", "<cmd>GBrowse<cr>", { desc = "Open in GitHub" })
-- Telescope-backed git pickers
map("n", "<leader>gb", function() require("telescope.builtin").git_branches() end, { desc = "Git branches" })
map("n", "<leader>gc", function() require("telescope.builtin").git_commits() end, { desc = "Git commits (repo)" })
map("n", "<leader>gC", function() require("telescope.builtin").git_bcommits() end, { desc = "Git commits (file)" })
map("n", "<leader>gt", function() require("telescope.builtin").git_status() end, { desc = "Git status" })
-- lazygit / gitui in a floating terminal
local function git_term(cmd)
  return function()
    if vim.fn.finddir(".git", vim.fn.getcwd() .. ";") ~= "" then
      vim.cmd("TermExec cmd='" .. cmd .. " && exit'")
    else
      vim.notify("Not a git repository", vim.log.levels.WARN)
    end
  end
end
if vim.fn.executable("lazygit") == 1 then
  map("n", "<leader>gg", git_term("lazygit"), { desc = "ToggleTerm lazygit" })
elseif vim.fn.executable("gitui") == 1 then
  map("n", "<leader>gg", git_term("gitui"), { desc = "ToggleTerm gitui" })
end

-- ---------------------------------------------------------------------------
-- File browsers / navigation
-- ---------------------------------------------------------------------------
if vim.fn.executable("yazi") == 1 then
  map("n", "<leader>r", "<cmd>Yazi<cr>", { desc = "File browser (yazi)" })
end
map("n", "<leader>e", "<cmd>Neotree toggle<cr>", { desc = "Neotree" })
map("n", "<leader>i", function() require("aerial").toggle() end, { desc = "Aerial outline" })

-- Session manager  [<leader>S]
map("n", "<leader>Sl", "<cmd>SessionManager! load_last_session<cr>", { desc = "Load last session" })
map("n", "<leader>Ss", "<cmd>SessionManager! save_current_session<cr>", { desc = "Save this session" })
map("n", "<leader>Sd", "<cmd>SessionManager! delete_session<cr>", { desc = "Delete session" })
map("n", "<leader>Sf", "<cmd>SessionManager! load_session<cr>", { desc = "Search sessions" })
map("n", "<leader>S.", "<cmd>SessionManager! load_current_dir_session<cr>", { desc = "Load cwd session" })

-- ---------------------------------------------------------------------------
-- smart-splits (window nav + resize)
-- ---------------------------------------------------------------------------
local ss = function(fn) return function() require("smart-splits")[fn]() end end
map("n", "<C-h>", ss("move_cursor_left"), { desc = "Move to left split" })
map("n", "<C-j>", ss("move_cursor_down"), { desc = "Move to below split" })
map("n", "<C-k>", ss("move_cursor_up"), { desc = "Move to above split" })
map("n", "<C-l>", ss("move_cursor_right"), { desc = "Move to right split" })
map("n", "<C-Up>", ss("resize_up"), { desc = "Resize split up" })
map("n", "<C-Down>", ss("resize_down"), { desc = "Resize split down" })
map("n", "<C-Left>", ss("resize_left"), { desc = "Resize split left" })
map("n", "<C-Right>", ss("resize_right"), { desc = "Resize split right" })

-- ---------------------------------------------------------------------------
-- Telescope  [<leader>f]
-- ---------------------------------------------------------------------------
local tb = function(name, opts) return function() require("telescope.builtin")[name](opts or {}) end end
map("n", "<leader>f<CR>", tb("resume"), { desc = "Resume previous search" })
map("n", "<leader>f'", tb("marks"), { desc = "Find marks" })
map("n", "<leader>fa", function()
  require("telescope.builtin").find_files({ prompt_title = "Config Files", cwd = vim.fn.stdpath("config"), follow = true })
end, { desc = "Find nvim config files" })
map("n", "<leader>fB", tb("buffers"), { desc = "Find buffers" })
map("n", "<leader>fw", tb("grep_string"), { desc = "Find word under cursor" })
map("n", "<leader>fC", tb("commands"), { desc = "Find commands" })
map("n", "<leader>fh", tb("help_tags"), { desc = "Find help" })
map("n", "<leader>fk", tb("keymaps"), { desc = "Find keymaps" })
map("n", "<leader>fm", tb("man_pages"), { desc = "Find man" })
map("n", "<leader>fn", function() require("telescope").extensions.notify.notify() end, { desc = "Find notifications" })
map("n", "<leader>fo", tb("oldfiles"), { desc = "Find recent" })
map("n", "<leader>fv", tb("registers"), { desc = "Find vim registers" })
map("n", "<leader>ft", function() require("telescope.builtin").colorscheme({ enable_preview = true }) end, { desc = "Find themes" })
map("n", "<leader>fT", "<cmd>TodoTelescope<cr>", { desc = "Find todos" })
map("n", "<leader>ff", function()
  require("telescope.builtin").live_grep({
    additional_args = function() return { "--hidden", "--no-ignore" } end,
  })
end, { desc = "Find words in project" })
map("n", "<leader>fF", tb("live_grep"), { desc = "Find words in project (no hidden)" })
map("n", "<leader>f/", tb("current_buffer_fuzzy_find"), { desc = "Find words in current buffer" })
map("n", "<leader>fp", "<cmd>Telescope projects<cr>", { desc = "Find project" })
map("n", "<leader>fr", function() require("spectre").toggle() end, { desc = "Find and replace in project" })
map("n", "<leader>fb", function() require("spectre").toggle({ path = vim.fn.expand("%:t:p") }) end, { desc = "Find and replace in buffer" })
map("n", "<leader>fu", function() require("telescope").extensions.undo.undo() end, { desc = "Find in undo tree" })
map("n", "<leader>fy", function() require("telescope").extensions.neoclip.default() end, { desc = "Find yank history" })

-- ---------------------------------------------------------------------------
-- Terminal (toggleterm)
-- ---------------------------------------------------------------------------
map("n", "<leader>tt", "<cmd>ToggleTerm direction=float<cr>", { desc = "ToggleTerm float" })
map("n", "<leader>th", "<cmd>ToggleTerm size=10 direction=horizontal<cr>", { desc = "ToggleTerm horizontal" })
map("n", "<leader>tv", "<cmd>ToggleTerm size=80 direction=vertical<cr>", { desc = "ToggleTerm vertical" })
map("n", "<F7>", "<cmd>ToggleTerm<cr>", { desc = "Terminal" })
map("t", "<F7>", "<cmd>ToggleTerm<cr>", { desc = "Terminal" })
map("n", "<C-'>", "<cmd>ToggleTerm<cr>", { desc = "Terminal" })
map("t", "<C-'>", "<cmd>ToggleTerm<cr>", { desc = "Terminal" })
-- terminal window navigation
map("t", "<C-h>", "<cmd>wincmd h<cr>", { desc = "Terminal left nav" })
map("t", "<C-j>", "<cmd>wincmd j<cr>", { desc = "Terminal down nav" })
map("t", "<C-k>", "<cmd>wincmd k<cr>", { desc = "Terminal up nav" })
map("t", "<C-l>", "<cmd>wincmd l<cr>", { desc = "Terminal right nav" })

-- ---------------------------------------------------------------------------
-- BQN  [<leader>B]  (inline-eval maps are buffer-local in after/ftplugin/bqn.lua)
-- ---------------------------------------------------------------------------
if vim.fn.executable("bqn") == 1 then
  map("n", "<leader>Bi", "<cmd>TermExec cmd='bqn' direction=float<cr>", { desc = "Open BQN REPL" })
  map("n", "<leader>Bt", function()
    vim.cmd("write")
    require("toggleterm").exec("bqn " .. vim.fn.expand("%:p"), 1, 0, nil, "float")
  end, { desc = "Run file in terminal" })
  map("n", "<leader>Bk", function()
    if vim.bo.keymap == "bqn" then
      vim.bo.keymap, vim.bo.iminsert = "", 0
      vim.notify("BQN keymap OFF", vim.log.levels.INFO)
    else
      vim.bo.keymap, vim.bo.iminsert = "bqn", 1
      vim.notify("BQN keymap ON", vim.log.levels.INFO)
    end
  end, { desc = "Toggle BQN keymap" })
end

-- ---------------------------------------------------------------------------
-- Debugger  [<leader>d] + F-keys
-- ---------------------------------------------------------------------------
local dap = function(fn) return function() require("dap")[fn]() end end
map("n", "<F5>", dap("continue"), { desc = "Debugger: Start/Continue" })
map("n", "<S-F5>", dap("terminate"), { desc = "Debugger: Stop" })
map("n", "<C-F5>", dap("restart_frame"), { desc = "Debugger: Restart" })
map("n", "<F9>", dap("toggle_breakpoint"), { desc = "Debugger: Toggle Breakpoint" })
map("n", "<F10>", dap("step_over"), { desc = "Debugger: Step Over" })
map("n", "<F11>", dap("step_into"), { desc = "Debugger: Step Into" })
map("n", "<S-F11>", dap("step_out"), { desc = "Debugger: Step Out" })
map("n", "<S-F9>", function()
  vim.ui.input({ prompt = "Condition: " }, function(c) if c then require("dap").set_breakpoint(c) end end)
end, { desc = "Debugger: Conditional Breakpoint" })
map("n", "<leader>db", dap("toggle_breakpoint"), { desc = "Breakpoint (F9)" })
map("n", "<leader>dB", dap("clear_breakpoints"), { desc = "Clear Breakpoints" })
map("n", "<leader>dc", dap("continue"), { desc = "Start/Continue (F5)" })
map("n", "<leader>do", dap("step_over"), { desc = "Step Over (F10)" })
map("n", "<leader>dO", dap("step_out"), { desc = "Step Out (S-F11)" })
map("n", "<leader>di", dap("step_into"), { desc = "Step Into (F11)" })
map("n", "<leader>dq", dap("close"), { desc = "Close Session" })
map("n", "<leader>dQ", dap("terminate"), { desc = "Terminate Session (S-F5)" })
map("n", "<leader>dp", dap("pause"), { desc = "Pause" })
map("n", "<leader>dr", dap("restart_frame"), { desc = "Restart (C-F5)" })
map("n", "<leader>dR", function() require("dap").repl.toggle() end, { desc = "REPL" })
map("n", "<leader>ds", function() require("dap").run_to_cursor() end, { desc = "Run To Cursor" })
map("n", "<leader>du", function() require("dapui").toggle() end, { desc = "Debugger UI" })
map("n", "<leader>dh", function() require("dap.ui.widgets").hover() end, { desc = "Debugger Hover" })
map("n", "<leader>dE", function()
  vim.ui.input({ prompt = "Expression: " }, function(e) if e then require("dapui").eval(e, { enter = true }) end end)
end, { desc = "Evaluate Input" })
map("x", "<leader>dE", function() require("dapui").eval() end, { desc = "Evaluate Selection" })

-- ---------------------------------------------------------------------------
-- Tests  [<leader>T] (neotest + coverage)
-- ---------------------------------------------------------------------------
local nt = function(fn, arg) return function() require("neotest").run[fn](arg) end end
map("n", "<leader>Tu", nt("run"), { desc = "Unit" })
map("n", "<leader>Ts", nt("stop"), { desc = "Stop unit" })
map("n", "<leader>Tf", function() require("neotest").run.run(vim.fn.expand("%")) end, { desc = "File" })
map("n", "<leader>Td", function() require("neotest").run.run({ strategy = "dap" }) end, { desc = "Unit in debugger" })
map("n", "<leader>Tt", function() require("neotest").summary.toggle() end, { desc = "Neotest summary" })
map("n", "<leader>TT", function() require("neotest").output_panel.toggle() end, { desc = "Output panel" })
map("n", "<leader>Tc", function()
  require("coverage").load(false)
  require("coverage").summary()
end, { desc = "Coverage" })
map("n", "<leader>TC", ui.toggle_coverage_signs, { desc = "Coverage signs (toggle)" })

-- ---------------------------------------------------------------------------
-- Folds (nvim-ufo)
-- ---------------------------------------------------------------------------
map("n", "zR", function() require("ufo").openAllFolds() end, { desc = "Open all folds" })
map("n", "zM", function() require("ufo").closeAllFolds() end, { desc = "Close all folds" })
map("n", "zr", function() require("ufo").openFoldsExceptKinds() end, { desc = "Fold less" })
map("n", "zm", function() require("ufo").closeFoldsWith() end, { desc = "Fold more" })
map("n", "zp", function() require("ufo").peekFoldedLinesUnderCursor() end, { desc = "Peek fold" })

-- ---------------------------------------------------------------------------
-- Docs  [<leader>D]
-- ---------------------------------------------------------------------------
map("n", "<leader>Dp", "<cmd>silent! MarkdownPreview<cr>", { desc = "Markdown preview" })

-- ---------------------------------------------------------------------------
-- Hop  +  fun
-- ---------------------------------------------------------------------------
map({ "n", "x" }, "<C-m>", "<cmd>silent! HopWord<cr>", { desc = "Hop to word" })
map("n", "<leader><leader>", function()
  local ok = pcall(vim.cmd, "CellularAutomaton game_of_life")
  if not ok then vim.notify("Needs a treesitter parser for this filetype", vim.log.levels.WARN) end
end, { desc = "Game of life" })

-- cmdline wildmenu arrow fix (neovim bug #9953)
for lhs, alt in pairs({ ["<Up>"] = "<Left>", ["<Down>"] = "<Right>", ["<Left>"] = "<Up>", ["<Right>"] = "<Down>" }) do
  map("c", lhs, function() return vim.fn.wildmenumode() == 1 and alt or lhs end, { expr = true, desc = "Wildmenu nav fix" })
end
