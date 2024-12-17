{ pkgs, config, ... }:
{
  home.stateVersion = "22.11";  #... This is here for backwards compatibility, don't change

  home.packages = with pkgs; [
    bandwhich
    bottom
    browsh
    ddgr
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
    (lib.hiPrio parallel)  #... Higher priority than collision from llama-cpp
    pre-commit
    procps
    procs
    rclone
    rclone               #... Manage cloud storage
    ripgrep
    shellcheck
    tree-sitter
    tuir                 #... Text UI reddit
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

    ##... AI tools
    ollama
    llama-cpp

    ##... Automation
    ansible
    sshpass

    ##... Networking
    arp-scan
    nmap
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
