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
      save = 10000;                  #... Save 10K lines of history
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
}
