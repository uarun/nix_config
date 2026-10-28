-- Keymaps are automatically loaded on the VeryLazy event
-- https://www.lazyvim.org/configuration/general

local map = vim.keymap.set

-- Terminal splits for CLI AI tools (Claude Code, kiro-cli)
map("n", "<leader>at", function()
  Snacks.terminal(nil, { win = { position = "right", width = 0.4 } })
end, { desc = "Terminal (AI tools - right)" })

map("n", "<leader>ah", function()
  Snacks.terminal(nil, { win = { position = "bottom", height = 0.3 } })
end, { desc = "Terminal (AI tools - bottom)" })

-- Better terminal escape
map("t", "<C-/>", "<cmd>close<cr>", { desc = "Hide Terminal" })
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Enter Normal Mode" })

-- Window navigation from terminal
map("t", "<C-h>", "<cmd>wincmd h<cr>", { desc = "Go to Left Window" })
map("t", "<C-j>", "<cmd>wincmd j<cr>", { desc = "Go to Lower Window" })
map("t", "<C-k>", "<cmd>wincmd k<cr>", { desc = "Go to Upper Window" })
map("t", "<C-l>", "<cmd>wincmd l<cr>", { desc = "Go to Right Window" })
