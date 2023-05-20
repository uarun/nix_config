{ pkgs, ... }: 
{
  home.stateVersion = "22.11";  #... This is here for backwards compatibility, don't change

  home.packages = with pkgs; [
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
    ./programs/neovim.nix
    ./programs/ssh.nix
    ./programs/zoxide.nix
    ./programs/zsh.nix
  ];

  home.file.".inputrc".source = ./dotfiles/inputrc;
}
