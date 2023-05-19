{ pkgs, ... }: 
{
  home.stateVersion = "22.11";  #... This is here for backwards compatibility, don't change

  home.packages = with pkgs; [
  ];

  home.sessionVariables = {
    PAGER = "less";
    EDITOR = "vim";
  };

  home.file.".inputrc".source = ./dotfiles/inputrc;

  programs.bat.enable = true;
  programs.bat.config.theme = "Solarized (light)";

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

    defaultKeymap = "viins";
  };

  programs.git = {
    enable = true;
    userName = "Arun Udayashankar";
    userEmail = "arunkumar.u@gmail.com";

    extraConfig = {
      github.user = "uarun";
    };
  };

  programs.exa = {
    enable = true;
    enableAliases = true;
    git = true;
    icons = true;
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
    enableNushellIntegration = false;
  };
}
