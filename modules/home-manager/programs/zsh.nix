{
  config,
  lib,
  pkgs,
  ...
}: {
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    dotDir = ".config/zsh";

    localVariables = {
      LANG = "en_US.UTF-8";
      DEFAULT_USER = "${config.home.username}";
      TERM = "xterm-256color";
    };

    history = {
      extended = true;                #... Save timestamps into history file
      save = 500000;                  #... Save 500K lines of history
      size = 100000;                  #... Number of history lines to keep
      share = true;                   #... Share history between zsh sessions
      expireDuplicatesFirst = true;
      ignoreSpace = true;
    };

    historySubstringSearch.enable = true;

    ### defaultKeymap = "viins";

    shellAliases = {
      ls  = "ls --color=auto -F -h";
      l   = "eza --icons --git-ignore --git -F --extended";
      ll  = "eza --icons --git-ignore --git -F --extended -l";
      lt  = "eza --icons --git-ignore --git -F --extended -T";
      llt = "eza --icons --git-ignore --git -F --extended -l -T";

      hmswitch = "home-manager switch --flake github:uarun/nix_config#$(id -un)@x86_64-linux";

    } //   #... Union
    pkgs.lib.optionalAttrs pkgs.stdenv.isDarwin {
      dwswitch       = "pushd ~; darwin-rebuild switch --flake ~/nix_config/.#$(id -un)@aarch64-darwin; popd";
      dwswitch_trace = "pushd ~; darwin-rebuild switch --flake ~/nix_config/.#$(id -un)@aarch64-darwin --show-trace; popd";
      dwclean        = "pushd ~; sudo nix-env --delete-generations +7 --profile /nix/var/nix/profiles/system; sudo nix-collect-garbage --delete-older-than 30d; nix store optimise; popd";
      dwupdate       = "pushd ~/nix_config; nix flake update; /opt/homebrew/bin/brew update; popd; dwswitch; /opt/homebrew/bin/brew upgrade; /opt/homebrew/bin/brew upgrade --cask --greedy; dwshowupdates";
      dwshowupdates  = ''zsh -c "nix store diff-closures /nix/var/nix/profiles/system-*-link(om[2]) /nix/var/nix/profiles/system-*-link(om[1])"'';
    };

    envExtra = ''
      source ${../dotfiles/init_nix.sh}
    '';

    initExtraFirst = ''
      source ${../dotfiles/p10k.zsh}
      source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme

      # Enable powerlevel10k instant prompt
      if [[ -r "$\{XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-$\{(%):-%n}.zsh" ]]; then
        source "$\{XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-$\{(%):-%n}.zsh"
      fi
    '';

    initExtra = ''
      set -o vi
      bindkey -v

      #... Key bindings
      bindkey '^a' beginning-of-line
      bindkey '^e' end-of-line

      # I prefer for up/down and j/k to do partial searches if there is
      # already text in play, rather than just normal through history
      bindkey '^[[A' up-line-or-search
      bindkey '^[[B' down-line-or-search
      bindkey -M vicmd 'k' up-line-or-search
      bindkey -M vicmd 'j' down-line-or-search
      bindkey '^r' history-incremental-search-backward
      bindkey '^s' history-incremental-search-forward
      bindkey -M vicmd '/' history-incremental-pattern-search-backward      # default is vi-history-search-backward
      bindkey -M vicmd '?' vi-history-search-backward                       # default is vi-history-search-forward

      source ${../dotfiles/lscolors.sh}
    '';

    profileExtra = ''
      ${lib.optionalString pkgs.stdenvNoCC.isLinux "[[ -e /etc/profile ]] && source /etc/profile"}
    '';

    oh-my-zsh = {
      enable = true;
      plugins = [ "ssh-agent" ];
    };

  };
}
