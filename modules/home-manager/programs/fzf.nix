_: {
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;

    #... McFly owns Ctrl-R in zsh (its integration is sourced after fzf's), so
    #... drop fzf's binding rather than have both fight over the key.
    historyWidget.zsh.command = "";
  };
}
