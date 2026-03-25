{ pkgs, lib, config, ... }:
{
  home.stateVersion = "25.11";

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
    fastfetch
    procs
    tree-sitter

    #... Development tools
    awscli2
    eksctl
    fd
    gh                    #... GitHub CLI
    glab                  #... GitLab CLI
    just
    kubectl
    lazygit
    liquibase
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
    yq

    #... Languages and build tools
    coursier             #... Scala
    gcc
    go
    gnumake
    nodejs_24
    nodePackages.typescript-language-server
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

    #... Container tools
    docker
    docker-compose
  ] ++
  lib.optionals pkgs.stdenv.hostPlatform.isLinux [
    corretto21           # Amazon Corretto OpenJDK 21 (Linux only)
    snowsql              # Only available on x86_64-linux
  ] ++
  lib.optionals pkgs.stdenv.hostPlatform.isDarwin [
    jdk21               # OpenJDK 21 (macOS only, Linux uses Corretto)
    colima              #... Lightweight Docker VM for macOS (replaces Docker Desktop)
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
  home.file.".config/nix/nix.conf".text = "experimental-features = nix-command flakes\n";
  fonts.fontconfig.enable = true;
}
