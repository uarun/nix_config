local o = vim.opt
local g = vim.g

-- Keybinds
local keymap = vim.api.nvim_set_keymap
local opts   = { silent = true, noremap = true }

g.mapleader = ' '

keymap("n", '<C-n>', ':Telescope live_grep <CR>',  opts)
keymap("n", '<C-f>', ':Telescope find_files <CR>', opts)

-- Indentation
o.smartindent = true
o.tabstop = 4
o.shiftwidth = 4
o.expandtab = true
o.scrolloff = 3

-- Set clipboard to use system clipboard
o.clipboard = "unnamedplus"

-- Use Mouse
o.mouse = "a"

-- UI Settings
o.cursorline = false
o.relativenumber = true
o.number = true

-- Misc
o.ignorecase = true
o.wrap = false
o.backup = false
o.writebackup = false
o.swapfile = false
o.errorbells = false

require('impatient')
require('impatient').enable_profile()
require('lualine').setup()
