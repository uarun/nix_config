-- Autocmds are automatically loaded on the VeryLazy event
-- https://www.lazyvim.org/configuration/general

local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

-- Disable diagnostics for markdown files (keeps LSP active)
autocmd("FileType", {
  group = augroup("disable_md_diagnostics", { clear = true }),
  pattern = { "markdown" },
  callback = function(event)
    vim.diagnostic.enable(false, { bufnr = event.buf })
  end,
})