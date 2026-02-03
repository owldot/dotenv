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
 --  { "folke/tokyonight.nvim", lazy = false },
})

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

-- move lines
vim.keymap.set("n", "<C-A-Down>", ":move +1<CR>", { silent = true })
vim.keymap.set("n", "<C-A-Up>", ":move -2<CR>", { silent = true })
vim.keymap.set("v", "<C-A-Down>", ":move '>+1<CR>gv", { silent = true })
vim.keymap.set("v", "<C-A-Up>", ":move '<-2<CR>gv", { silent = true })

-- autoformat

vim.api.nvim_create_autocmd("BufWritePre", {
  callback = function()
    vim.lsp.buf.format({ async = false })
  end,
})

-- sys
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undofile = true

-- expore
vim.opt.wildmenu = true
vim.opt.wildmode = { "longest", "list", "full" }

-- Telescope

local builtin = require("telescope.builtin")

vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Live grep" })
vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Buffers" })
vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Help" })
