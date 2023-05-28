{ pkgs, ... }: {

  home.file.".config/nvim/settings.lua".source = ../nvim/init.lua;

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    #... nvim plugin providers
    withNodeJs  = true;
    withRuby    = true;
    withPython3 = true;

    #... share vim plugins since nothing is specific to nvim
    plugins = with pkgs.vimPlugins; [
      #... basics
      vim-sensible
      vim-fugitive
      vim-sandwich
      vim-commentary
      vim-nix

      #... UI Plugins
      telescope-nvim
      gitsigns-nvim
      bufferline-nvim
      toggleterm-nvim
      (nvim-treesitter.withPlugins (_: pkgs.tree-sitter.allGrammars))  # better code coloring
      nvim-treesitter-textobjects                                      # movement based on syntax
      nvim-treesitter-context                                          # preserve current context (like func definition, for loop etc.)
      nvim-web-devicons                                                # pretty icons used by other plugins like lualine
      lualine-nvim                                                     # status bar

      #... Misc
      impatient-nvim                   # speeds startup times by caching lua bytecode
      which-key-nvim
    ];

    extraConfig = ''
      luafile ~/.config/nvim/settings.lua
    '';
  };
}
