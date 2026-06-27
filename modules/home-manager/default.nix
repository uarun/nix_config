{ pkgs, lib, ... }:
{
  home.stateVersion = "25.11";

  home.packages =
    with pkgs;
    [
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
      gh # ... GitHub CLI
      glab # ... GitLab CLI
      just
      k9s # ... Kubernetes cluster TUI
      kubectl
      kubectx # ... Fast kube context + namespace switching (provides kubectx & kubens)
      lazygit
      liquibase
      mermaid-cli
      pixi
      pandoc
      pnpm
      pre-commit
      procps
      ripgrep
      shellcheck
      tokei
      toxiproxy
      uv
      vscode
      yazi
      yq
      yubikey-manager # ... ykman CLI for YubiKey config (FIDO2/PIV/OATH)

      #... Coding-agent power tools (structural search/rewrite, lint/format, autonomous loops)
      ast-grep # ... AST-based code search & rewrite (sg) - syntax-aware refactors
      semgrep # ... Pattern-based static analysis & security scanning
      sd # ... Intuitive find/replace, safer than sed for agents
      ruff # ... Fast Python linter + formatter (pairs with uv)
      shfmt # ... Shell formatter (pairs with shellcheck)
      watchexec # ... Run commands on file change (edit->test loops)
      ripgrep-all # ... rg over PDFs, docx, zip, sqlite (rga)
      hyperfine # ... Statistical CLI benchmarking
      jless # ... Interactive JSON/YAML viewer
      mise # ... Polyglot runtime + task manager

      #... Agent self-verification guardrails (run before commit/push)
      typos # ... Source-code spell checker (identifiers/comments/docs)
      gitleaks # ... Secret scanning - block committed keys/tokens
      treefmt # ... Run every formatter in a repo via one command
      act # ... Run GitHub Actions locally before pushing
      trivy # ... Vulnerability + container + IaC scanning

      #... Per-ecosystem linters/formatters (matched to languages edited here)
      nixfmt # ... Nix formatter (RFC style)
      statix # ... Nix linter
      deadnix # ... Nix dead-code finder
      stylua # ... Lua formatter (neovim config)
      prettierd # ... Daemonized prettier (JS/TS) - fast in edit loops
      eslint_d # ... Daemonized eslint (JS/TS)
      golangci-lint # ... Aggregate Go linter

      #... Languages and build tools
      coursier # ... Scala
      gcc
      go
      cmake
      gnumake
      maven # ... Java build tool
      bun
      nodejs_24
      pyright
      typescript-language-server
      rustup

      #... Node global tools (managed here instead of npm -g)
      agent-browser
      (pkgs.callPackage ../../packages/node/ctx7.nix { })
      (pkgs.callPackage ../../packages/node/excalidraw-edit.nix { })

      #... Language learning/tools
      exercism

      #... Cloud storage and backup
      rclone
      restic

      #... Text processing and data
      # tuir                 #... Text UI reddit
      duckdb # ... In-process SQL on CSV/JSON/Parquet files (static binary, no deps)
      visidata

      #... AI tools
      llama-cpp
      (lib.hiPrio parallel) # ... Higher priority than collision from llama-cpp

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

      #... Fonts
      inter
      nerd-fonts.iosevka
      nerd-fonts.iosevka-term

      #... Graphics
      inkscape

      #... Media & terminal recording
      ffmpeg
      silicon
      vhs
      yt-dlp

      #... Archives and misc
      p7zip
      sc-im

      #... Container tools
      docker
      docker-compose
      lazydocker # ... Docker/Colima TUI (lazygit for containers)
    ]
    ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux [
      bubblewrap # bwrap sandbox (Linux only)
      chromium # Headless browser for puppeteer/agent-browser (Linux; macOS uses Homebrew cask)
      corretto21 # Amazon Corretto OpenJDK 21 (Linux only)
      snowsql # Only available on x86_64-linux
    ]
    ++ lib.optionals pkgs.stdenv.hostPlatform.isDarwin [
      jdk21 # OpenJDK 21 (macOS only, Linux uses Corretto)
      colima # ... Lightweight Docker VM for macOS (replaces Docker Desktop)

      #... Internet Computer (ICP) toolchain - prebuilt, darwin-only (not on work Linux hosts)
      (pkgs.callPackage ../../packages/icp/icp-cli.nix { })
      (pkgs.callPackage ../../packages/icp/ic-wasm.nix { })
      (pkgs.callPackage ../../packages/node/ic-mops.nix { }) # ... Motoko package manager (mops)
    ];

  home.sessionVariables = {
    EDITOR = "nvim";
    MANPAGER = "most";
    PAGER = "less";
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
    ./programs/tmux.nix
    ./programs/wezterm.nix
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
