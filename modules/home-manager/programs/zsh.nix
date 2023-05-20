{ pkgs, ... }:
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableAutosuggestions = true;
    enableSyntaxHighlighting = true;

    history = {
      extended = true;                #... Save timestamps into history file
      save = 500000;                  #... Save 500K lines of history
      share = true;                   #... Share history between zsh sessions
      expireDuplicatesFirst = true;
      ignoreSpace = true;
    };

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
  };
}
