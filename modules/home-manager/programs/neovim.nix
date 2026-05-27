{ pkgs, lib, config, ... }:
let
  # Local clone location of this repo, used for the live-edit lua symlink below.
  # Differs per host: this Mac clones to ~/nix_config (see dwswitch alias),
  # the Linux host clones to ~/repos/nix_config.
  neovimRepoPath =
    if pkgs.stdenv.isDarwin then
      "${config.home.homeDirectory}/nix_config"
    else
      "${config.home.homeDirectory}/repos/nix_config";

  # Treesitter grammars — all languages, compiled by Nix
  treesitter = pkgs.vimPlugins.nvim-treesitter.withAllGrammars;
  treesitterGrammars = pkgs.symlinkJoin {
    name = "nvim-treesitter-grammars";
    paths = treesitter.dependencies;
  };

  # All plugins provided to lazy.nvim via dev.path linkFarm.
  # These must cover all dependencies of the lang extras imported in initLua below.
  # If a plugin is missing here, dev.fallback = true will clone it from GitHub at runtime.
  plugins = with pkgs.vimPlugins; [
    # Core
    LazyVim
    lazy-nvim
    snacks-nvim

    # Completion
    { name = "blink.cmp"; path = blink-cmp; }
    friendly-snippets

    # UI
    bufferline-nvim
    lualine-nvim
    noice-nvim
    nui-nvim
    mini-icons

    # Colorschemes
    { name = "catppuccin"; path = catppuccin-nvim; }
    tokyonight-nvim  # required by LazyVim default; disabled in colorscheme.lua

    # Editor
    flash-nvim
    fzf-lua
    gitsigns-nvim
    grug-far-nvim
    neo-tree-nvim
    todo-comments-nvim
    trouble-nvim
    which-key-nvim

    # Coding
    conform-nvim
    nvim-lint
    nvim-lspconfig
    lazydev-nvim
    mini-ai
    mini-pairs
    ts-comments-nvim
    nvim-ts-autotag

    # Treesitter
    nvim-treesitter
    nvim-treesitter-textobjects

    # Lang extra dependencies
    crates-nvim
    markdown-preview-nvim
    nvim-jdtls
    render-markdown-nvim
    rustaceanvim
    SchemaStore-nvim
    venv-selector-nvim

    # Util
    persistence-nvim
    plenary-nvim
  ];

  # Convert plugin derivations to { name, path } for linkFarm
  mkEntryFromDrv = drv:
    if lib.isDerivation drv then
      { name = "${lib.getName drv}"; path = drv; }
    else
      drv;

  lazyPath = pkgs.linkFarm "lazy-plugins" (builtins.map mkEntryFromDrv plugins);
in
{
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    defaultEditor = true;

    withNodeJs = true;
    withRuby = true;
    withPython3 = true;

    # Only lazy.nvim is loaded as a Nix plugin — it bootstraps everything else
    plugins = with pkgs.vimPlugins; [ lazy-nvim ];

    extraPackages = with pkgs; [
      # Core tools (neovim runtime deps)
      ripgrep
      fd
      fzf
      lazygit
      git
      tree-sitter

      # Lua
      lua-language-server
      stylua

      # Nix
      nil
      nixfmt-rfc-style
      statix

      # Go
      gopls
      gofumpt
      gotools          # goimports
      delve

      # Rust
      rust-analyzer

      # TypeScript / JavaScript
      typescript-language-server
      prettierd
      eslint_d

      # Python
      pyright
      ruff

      # Java
      jdt-language-server

      # YAML
      yaml-language-server

      # JSON / HTML / CSS / ESLint
      vscode-langservers-extracted

      # Docker
      dockerfile-language-server
      docker-compose-language-service

      # Bash / Shell
      bash-language-server
      shellcheck
      shfmt

      # Scala
      metals
    ];

    initLua =
      # lua
      ''
        -- Treesitter grammars: append Nix-built parsers to runtimepath
        vim.opt.runtimepath:append("${pkgs.vimPlugins.nvim-treesitter}")
        vim.opt.runtimepath:append("${treesitterGrammars}")

        -- Bootstrap lazy.nvim with Nix-provided plugins
        require("lazy").setup({
          defaults = { lazy = true },
          dev = {
            path = "${lazyPath}",
            patterns = { "" },
            fallback = true,
          },
          spec = {
            { "LazyVim/LazyVim", import = "lazyvim.plugins" },

            -- Language extras (declared here instead of lazyvim.json)
            { import = "lazyvim.plugins.extras.lang.nix" },
            { import = "lazyvim.plugins.extras.lang.go" },
            { import = "lazyvim.plugins.extras.lang.rust" },
            { import = "lazyvim.plugins.extras.lang.typescript" },
            { import = "lazyvim.plugins.extras.lang.python" },
            { import = "lazyvim.plugins.extras.lang.java" },
            { import = "lazyvim.plugins.extras.lang.scala" },
            { import = "lazyvim.plugins.extras.lang.docker" },
            { import = "lazyvim.plugins.extras.lang.json" },
            { import = "lazyvim.plugins.extras.lang.yaml" },
            { import = "lazyvim.plugins.extras.lang.markdown" },
            { import = "lazyvim.plugins.extras.lang.toml" },

            -- Disable Mason (Nix provides all LSPs/formatters)
            { "mason-org/mason.nvim", enabled = false },
            { "mason-org/mason-lspconfig.nvim", enabled = false },

            -- Your custom plugin overrides
            { import = "plugins" },

            -- Treesitter: Nix handles grammars, disable ensure_installed
            { "nvim-treesitter/nvim-treesitter", build = "", opts = { ensure_installed = {} } },
          },
          rocks = { enabled = false },
          pkg = { enabled = false },
          install = { missing = false },
          change_detection = { enabled = false },
          checker = { enabled = false },
          lockfile = vim.fn.stdpath("data") .. "/lazy-lock.json",
          performance = {
            rtp = {
              disabled_plugins = {
                "gzip",
                "tarPlugin",
                "tohtml",
                "tutor",
                "zipPlugin",
              },
            },
          },
        })
      '';
  };

  # Symlink lua config directory - writable, instant iteration without rebuild.
  # Points at the local clone of this repo. The clone location differs per host
  # (this Mac uses ~/nix_config per the dwswitch alias; the Linux host uses
  # ~/repos/nix_config), so it is derived from neovimRepoPath below.
  xdg.configFile."nvim/lua" = {
    source = config.lib.file.mkOutOfStoreSymlink
      "${neovimRepoPath}/modules/home-manager/programs/nvim/lua";
    recursive = true;
  };
}
