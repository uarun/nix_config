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
    lnav
    miller
    most
    ncdu
    neofetch
    (lib.hiPrio parallel)  #... Higher priority than collision from llama-cpp
    pre-commit
    procps
    procs
    rclone               #... Manage cloud storage
    restic
    ripgrep
    shellcheck
    tree-sitter
    tuir                 #... Text UI reddit
    visidata

    #... Lang Packages
    coursier             #... Scala application and artifact manager
    gcc13
    go
    rustup
    nodejs_22
    gnumake

    #... Lang Misc
    exercism

    #... Dev Tools
    toxiproxy
    jetbrains.idea-community
    vscode

    ##... AI tools
    llama-cpp

    ##... Automation
    ansible
    sshpass

    ##... Networking
    arp-scan
    nmap

    ##... Cheatsheets
    cht-sh
    navi

    ##... Messaging
    protobuf_24            #... Protocol Buffers v2.4.x

    ##... Clipboard Management
    xsel      #... X11 clipboard utility
    xclip     #... Alternative X11 clipboard tool

    ##... Misc
    p7zip
    sc-im
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
