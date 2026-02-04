-- lazy.nvim bootstrap
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end

vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
  },
  {
    'folke/tokyonight.nvim',
    lazy = false,
    priority = 1000,
    config = function()
      require('tokyonight').setup({
        style = 'night',
        light_style = 'day',
        terminal_colors = true,
      })

      vim.cmd 'colorscheme tokyonight'
    end,
  },

  {"tpope/vim-fugitive"},
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require('gitsigns').setup({
        on_attach = function(bufnr)
          local gitsigns = require('gitsigns')

          local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
          end

          -- Navigation
          map('n', ']c', function()
            if vim.wo.diff then
              vim.cmd.normal({']c', bang = true})
            else
              gitsigns.nav_hunk('next')
            end
          end)

          map('n', '[c', function()
            if vim.wo.diff then
              vim.cmd.normal({'[c', bang = true})
            else
              gitsigns.nav_hunk('prev')
            end
          end)

          -- Actions
          --  map('n', '<leader>hs', gitsigns.stage_hunk)
          --  map('n', '<leader>hr', gitsigns.reset_hunk)

          --   map('v', '<leader>hs', function()
          --     gitsigns.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
          --  end)

          --map('v', '<leader>hr', function()
          --  gitsigns.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') })
          --end)

          --map('n', '<leader>hS', gitsigns.stage_buffer)
          --map('n', '<leader>hR', gitsigns.reset_buffer)
          --map('n', '<leader>hp', gitsigns.preview_hunk)
          --map('n', '<leader>hi', gitsigns.preview_hunk_inline)

          map('n', '<leader>hb', function()
            gitsigns.blame_line({ full = true })
          end)

          map('n', '<leader>hd', gitsigns.diffthis)

          -- map('n', '<leader>hD', function()
          --   gitsigns.diffthis('~')
          -- end)

          -- map('n', '<leader>hQ', function() gitsigns.setqflist('all') end)
          -- map('n', '<leader>hq', gitsigns.setqflist)

          -- Toggles
          map('n', '<leader>hB', gitsigns.toggle_current_line_blame)
          map('n', '<leader>tw', gitsigns.toggle_word_diff)

          -- Text object
          --    map({'o', 'x'}, 'ih', gitsigns.select_hunk)
        end
      })
    end,
  },
})


-- LSP
require("lsp")


-- Clipboard
vim.opt.clipboard = "unnamedplus"

-- Mouse
vim.opt.mouse = "a"

-- Line numbers
vim.opt.number = true
vim.opt.relativenumber = false

-- Colors
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
vim.cmd.colorscheme("tokyonight-night")

-- Syntax highlighting (mostly legacy)
vim.cmd("syntax on")

vim.opt.path:append("**")

-- Highlight current line
vim.opt.cursorline = true

-- leader
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- invisible chars
vim.opt.list = true
vim.opt.listchars = {
  tab = "→ ",
  trail = "·",
  nbsp = "␣",
}

-- auto save
vim.api.nvim_create_autocmd({ "BufLeave", "FocusLost" }, {
  pattern = "*",
  command = "silent! update",
})

vim.api.nvim_create_autocmd("QuitPre", {
  pattern = "*",
  command = "wall"
})

-- move lines
vim.keymap.set("n", "<A-Down>", ":move .+1<CR>==", { silent = true })
vim.keymap.set("n", "<A-Up>", ":move .-2<CR>==", { silent = true })
vim.keymap.set("v", "<A-Down>", ":move '>+1<CR>gv=gv", { silent = true })
vim.keymap.set("v", "<A-Up>", ":move '<-2<CR>gv=gv", { silent = true })

-- autoformat

vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  callback = function()
    if vim.lsp.get_active_clients({bufnr = 0})[1] then
      vim.lsp.buf.format({ async = false })
    end

    vim.cmd([[%s/\u00A0/ /ge]])

    local spaces = string.rep(" ", vim.o.tabstop)
    vim.cmd([[%s/\t/]] .. spaces .. [[/ge]])

    vim.cmd([[%s/\s\+$//e]])
  end,
})

vim.opt.fixendofline = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.softtabstop = 2

-- highlight

vim.keymap.set("n", "<Esc>", ":nohlsearch<CR>")

-- sys
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undofile = true

vim.api.nvim_create_autocmd("BufReadPost", {
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1]>0 and mark[1] <= lcount then
      vim.cmd("normal! g`\"")
    end
  end
})

vim.opt.laststatus = 3
vim.opt.showmode = false
_G.stl_git = function()
  return vim.b.gitsigns_head and (" " .. vim.b.gitsigns_head) or ""
end

vim.o.statusline = table.concat({
  " %f",          -- file path (relative)
  " %m",          -- [+] if modified
  " %r",          -- [RO] if readonly
  " %h",          -- [help] etc
  " %w",          -- [Preview] etc
  " %=",          -- split left/right
  " %{v:lua.stl_git()}",
  "  %y",         -- filetype
  "  %l:%c",      -- line:col
  "  %p%% ",      -- percent through file
})

-- expore
vim.opt.wildmenu = true
vim.opt.wildmode = { "longest", "list", "full" }

-- Telescope

local builtin = require("telescope.builtin")

vim.keymap.set("n", "<leader>fo", builtin.oldfiles, { desc = "Recent files" })
vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Live grep" })
vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Buffers" })
vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Help" })


