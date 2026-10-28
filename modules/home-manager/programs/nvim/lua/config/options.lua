-- Options are automatically loaded before lazy.nvim startup
-- https://www.lazyvim.org/configuration/general
-- Only non-LazyVim-default overrides below.

-- Undercurl support through tmux
if vim.env.TMUX then
  vim.g.terminal_emulator = "tmux"
  vim.cmd([[let &t_Cs = "\e[4:3m"]])
  vim.cmd([[let &t_Ce = "\e[4:0m"]])
end

-- Performance
vim.opt.redrawtime = 1500
vim.opt.lazyredraw = false

-- Disable swap (Nix store is immutable, data is in git)
vim.opt.swapfile = false
