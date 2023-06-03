{ pkgs, ... }:
{
  programs.mcfly = {
    enable = true;
    enableZshIntegration = true;
    fuzzySearchFactor = 2;             #... 0 = off, 2-5 range gets good results according to docs
    keyScheme = "vim";
  };
}
