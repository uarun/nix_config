{ pkgs, ... }:
{
  programs.git = {
    enable = true;

    extraConfig = {
      github.user = "uarun";
    };
  };
}
