{ pkgs, ... }: {

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    #... nvim plugin providers
    withNodeJs  = true;
    withRuby    = true;
    withPython3 = true;

    plugins = with pkgs.vimPlugins; [
    ];
  };
}
