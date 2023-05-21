{ pkgs, ... }: {
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableAutosuggestions = true;
    enableSyntaxHighlighting = true;

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
      ls  = "ls --color=auto -F";
      l   = "exa --icons --git-ignore --git -F --extended";
      ll  = "exa --icons --git-ignore --git -F --extended -l";
      lt  = "exa --icons --git-ignore --git -F --extended -T";
      llt = "exa --icons --git-ignore --git -F --extended -l -T";
    } // pkgs.lib.optionalAttrs pkgs.stdenv.isDarwin {
      dwswitch       = "pushd ~; darwin-rebuild switch --flake ~/nix_config/.#$(hostname -s); popd";
      dwswitch_trace = "pushd ~; darwin-rebuild switch --flake ~/nix_config/.#$(hostname -s) --show-trace; popd";
    };

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
    '';
  };
}
