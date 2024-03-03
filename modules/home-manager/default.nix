{ pkgs, config, ... }:
{
  home.stateVersion = "22.11";  #... This is here for backwards compatibility, don't change

  home.packages = with pkgs; [
    bottom
    du-dust
    duf
    fd
    glances
    gping
    gron
    gtop
    httpie
    kalker
    miller
    most
    ncdu
    neofetch
    parallel
    pre-commit
    procps
    procs
    ripgrep
    shellcheck
    tree-sitter
    visidata
    xsv

    #... Lang Packages
    coursier             #... Scala application and artifact manager
    gcc13
    go
    rustup

    #... Lang Misc
    exercism

    #... Dev Tools
    toxiproxy
    jetbrains.idea-ultimate
  ];

  home.sessionVariables = {
    EDITOR   = "nvim";
    MANPAGER = "most";
    PAGER    = "less";
  };

  imports = [
    ./aliases.nix
    ./programs/bat.nix
    ./programs/eza.nix
    ./programs/fzf.nix
    ./programs/git.nix
    ./programs/kitty.nix
    ./programs/neovim.nix
    ./programs/nushell.nix
    ./programs/mcfly.nix
    ./programs/ssh.nix
    ./programs/tldr.nix
    ./programs/zoxide.nix
    ./programs/zsh.nix
  ];

  programs = {
    home-manager = {
      enable = true;
    };

    broot.enable = true;
    btop.enable = true;
    dircolors.enable = true;
    htop.enable = true;
    jq.enable = true;
    less.enable = true;
    man.enable = true;
    nix-index.enable = true;
  };

  home.file.".inputrc".source = ./dotfiles/inputrc;
  fonts.fontconfig.enable = true;
}
