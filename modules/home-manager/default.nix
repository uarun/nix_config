{ pkgs, config, ... }:
{
  home.stateVersion = "22.11";  #... This is here for backwards compatibility, don't change

  home.packages = with pkgs; [
    duf
    du-dust
  ];

  home.sessionVariables = {
    PAGER  = "less";
    EDITOR = "nvim";
  };

  imports = [
    ./aliases.nix
    ./programs/bat.nix
    ./programs/exa.nix
    ./programs/fzf.nix
    ./programs/git.nix
    ./programs/kitty.nix
    ./programs/neovim.nix
    ./programs/nushell.nix
    ./programs/ssh.nix
    ./programs/tldr.nix
    ./programs/zoxide.nix
    ./programs/zsh.nix
  ];

  programs = {
    btop.enable = true;
    dircolors.enable = true;
  };

  home.file.".inputrc".source = ./dotfiles/inputrc;
}
