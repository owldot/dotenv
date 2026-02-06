-- Colors
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"

-- Clipboard
vim.opt.clipboard = "unnamedplus"

-- Mouse
vim.opt.mouse = "a"

-- Line numbers
vim.opt.number = true
vim.opt.relativenumber = false

-- Highlight current line
vim.opt.cursorline = true

-- Invisible chars
vim.opt.list = true
vim.opt.listchars = {
  tab = "→ ",
  trail = "·",
  nbsp = "␣",
}

-- Indentation
vim.opt.fixendofline = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.softtabstop = 2

-- System
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undofile = true

-- Status line
vim.opt.laststatus = 2
vim.opt.showmode = false  -- Hide default mode indicator

_G.stl_git = function()
  return vim.b.gitsigns_head and (" " .. vim.b.gitsigns_head) or ""
end

_G.stl_mode = function()
  local modes = {
    n = "NORMAL",
    i = "INSERT",
    v = "VISUAL",
    V = "V-LINE",
    ["\22"] = "V-BLOCK",
    c = "COMMAND",
    R = "REPLACE",
    t = "TERMINAL",
  }
  return " " .. (modes[vim.fn.mode()] or "UNKNOWN") .. " "
end

vim.o.statusline = table.concat({
  "%{v:lua.stl_mode()}",  -- mode
  " %<%f",                 -- file path (truncate here if needed)
  " %m",                   -- [+] if modified
  " %r",                   -- [RO] if readonly
  " %=",                   -- split left/right
  " %{v:lua.stl_git()}",   -- git branch
  "  %y",                  -- filetype
  "  %l:%c",               -- line:col
  "  %p%% ",               -- percent through file
})

-- Command line completion
vim.opt.wildmenu = true
vim.opt.wildmode = { "longest", "list", "full" }

-- Session management - only save visible windows/files
vim.opt.sessionoptions = {
  "curdir",    -- current directory
  "tabpages",  -- all tab pages and their windows
  "winsize",   -- window sizes
}

-- Keymaps

vim.keymap.set("n", "<leader>p", "_dP") -- don't replace the register
vim.keymap.set("v", "<leader>p", "_dP") -- don't replace the register
vim.keymap.set("n", "<leader>d", "_d") -- don't replace the register
vim.keymap.set("v", "<leader>d", "_d") -- don't replace the register

vim.keymap.set("n", "<leader>o", ":Ex<CR>", { silent = true })

vim.keymap.set("n", "[b", ":bp<CR>", { silent = true })
vim.keymap.set("n", "]b", ":bn<CR>", { silent = true })

-- Move lines
vim.keymap.set("n", "<A-Down>", ":move .+1<CR>==", { silent = true })
vim.keymap.set("n", "<A-Up>", ":move .-2<CR>==", { silent = true })
vim.keymap.set("v", "<A-Down>", ":move '>+1<CR>gv=gv", { silent = true })
vim.keymap.set("v", "<A-Up>", ":move '<-2<CR>gv=gv", { silent = true })

-- Center on scroll
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- Clear highlight
vim.keymap.set("n", "<Esc>", ":nohlsearch<CR>")

-- Telescope
local builtin = require("telescope.builtin")
vim.keymap.set('n', '<leader>fs', function()
  local glob = vim.fn.input('File mask (e.g. **/*.lua, empty for all): ')
  require("telescope").extensions.live_grep_args.live_grep_args({
    additional_args = glob ~= '' and function()
      return { '--glob', glob }
    end or nil,
  })
end, { desc = 'Live grep (file mask)' })
vim.keymap.set("n", "<leader>fo", builtin.oldfiles, { desc = "Recent files" })
vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Live grep" })
vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Buffers" })
vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Help" })

-- Git
vim.keymap.set("n", "<leader>gr", ":Gitsigns refresh<CR>", { desc = "Refresh git branch" })

-- Autocommands

-- Auto save on focus lost (not on buffer switch)
vim.api.nvim_create_autocmd("FocusLost", {
  pattern = "*",
  command = "silent! update",
})

-- Autoformat and cleanup
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  callback = function()
    -- LSP format if available
    if vim.lsp.get_active_clients({bufnr = 0})[1] then
      vim.lsp.buf.format({ async = false })
    end

    -- Strip trailing whitespace
    vim.cmd([[%s/\s\+$//e]])
  end,
})

-- Restore last cursor position
vim.api.nvim_create_autocmd("BufReadPost", {
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      vim.cmd("normal! g`\"")
    end
  end
})

-- Session save on exit
--vim.api.nvim_create_autocmd("VimLeavePre", {
--  callback = function()
--    vim.cmd('mksession! ~/.config/nvim/session.vim')
--  end
--})

-- -- Session restore on startup (deferred to not interfere with LSP)
-- vim.api.nvim_create_autocmd("VimEnter", {
--   callback = function()
--     local session_file = vim.fn.expand('~/.config/nvim/session.vim')
--     if vim.fn.argc() == 0 and vim.fn.filereadable(session_file) == 1 then
--       vim.cmd('source ' .. session_file)
--     end
--   end,
-- })

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "lua", "rust", "ruby" },
  callback = function()
    vim.opt_local.foldmethod = "expr"
    vim.opt_local.foldexpr = "nvim_treesitter#foldexpr()"
    vim.opt_local.foldlevel = 99
  end,
})
