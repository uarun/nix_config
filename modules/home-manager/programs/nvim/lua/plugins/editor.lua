return {
  -- fzf-lua aesthetic tweaks
  {
    "ibhagwan/fzf-lua",
    opts = {
      winopts = {
        backdrop = 100,
        preview = { layout = "vertical", vertical = "up:55%" },
      },
    },
  },

  -- Neo-tree: cleaner look
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      filesystem = {
        filtered_items = { hide_dotfiles = false, hide_gitignored = false },
      },
    },
  },
}
