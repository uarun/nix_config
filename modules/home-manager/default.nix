{ pkgs, config, ... }:
{
  home.stateVersion = "22.11";  #... This is here for backwards compatibility, don't change

  home.packages = with pkgs; [
    #... System monitoring and utilities
    bandwhich
    bottom
    browsh
    ddgr
    dust
    duf
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
    procs
    tree-sitter

    #... Development tools
    awscli2
    eksctl
    fd
    gh                    #... GitHub CLI
    just
    kubectl
    lazygit
    mermaid-cli
    pnpm
    pre-commit
    procps
    ripgrep
    shellcheck
    toxiproxy
    uv
    vscode
    yazi

    #... Languages and build tools
    coursier             #... Scala
    gcc
    go
    gnumake
    nodejs_25
    rustup

    #... Language learning/tools
    exercism

    #... Cloud storage and backup
    rclone
    restic

    #... Text processing and data
    # tuir                 #... Text UI reddit
    visidata

    #... AI tools
    llama-cpp
    (lib.hiPrio parallel)  #... Higher priority than collision from llama-cpp

    #... Automation and infrastructure
    ansible
    sshpass

    #... Networking
    arp-scan
    nmap

    #... Documentation and cheatsheets
    cht-sh
    navi

    #... Clipboard management (Linux)
    xsel
    xclip

    #... Archives and misc
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
