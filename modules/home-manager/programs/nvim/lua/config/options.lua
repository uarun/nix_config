-- Options are automatically loaded before lazy.nvim startup
-- https://www.lazyvim.org/configuration/general
-- Only non-LazyVim-default overrides below.

-- True color support (Ghostty + tmux)
vim.opt.termguicolors = true

-- Undercurl support through tmux
if vim.env.TMUX then
  vim.g.terminal_emulator = "tmux"
  vim.cmd([[let &t_Cs = "\e[4:3m"]])
  vim.cmd([[let &t_Ce = "\e[4:0m"]])
end

-- Performance
vim.opt.updatetime = 200
vim.opt.timeoutlen = 300
vim.opt.redrawtime = 1500
vim.opt.lazyredraw = false

-- UI tweaks beyond LazyVim defaults
vim.opt.sidescrolloff = 8
vim.opt.pumheight = 10

-- Disable swap (Nix store is immutable, data is in git)
vim.opt.swapfile = false
