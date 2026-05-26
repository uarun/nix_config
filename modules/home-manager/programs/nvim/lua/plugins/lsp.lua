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
        rust_analyzer = {
          settings = {
            ["rust-analyzer"] = {
              check = { command = "clippy" },
              cargo = { allFeatures = true },
            },
          },
        },
        ts_ls = {},
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
        metals = {},
      },
    },
  },
}
