return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        lua_ls = {},
        nil_ls = {},
        gopls = {
          settings = {
            gopls = {
              analyses = { unusedparams = true, shadow = true },
              staticcheck = true,
              gofumpt = true,
            },
          },
        },
        pyright = {
          settings = {
            python = {
              analysis = { typeCheckingMode = "standard" },
            },
          },
        },
        yamlls = {
          settings = {
            yaml = {
              schemaStore = { enable = true, url = "" },
            },
          },
        },
        jsonls = {},
        dockerls = {},
        docker_compose_language_service = {},
        bashls = {},
      },
    },
  },
  -- The lang.rust extra starts rust-analyzer through rustaceanvim, not lspconfig
  {
    "mrcjkb/rustaceanvim",
    opts = {
      server = {
        default_settings = {
          ["rust-analyzer"] = {
            check = { command = "clippy" },
            cargo = { allFeatures = true },
          },
        },
      },
    },
  },
  -- Use the metals on PATH (from neovim.nix) instead of nvim-metals' own install
  {
    "scalameta/nvim-metals",
    opts = function(_, opts)
      opts.settings = vim.tbl_extend("force", opts.settings or {}, { useGlobalExecutable = true })
      return opts
    end,
  },
}
