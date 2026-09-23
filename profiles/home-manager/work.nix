{ pkgs, ... }:
{
  imports = [ ../../modules/home-manager/nix-daemon-config.nix ];

  #... Atlassian Teamwork Graph CLI - work-only, so not in the shared package set.
  #... Nix owns the binary; `twg login` and `twg skills install` still write to
  #... ~/.config/twg and agent dirs on first use.
  home.packages = [ (pkgs.callPackage ../../packages/atlassian/twg.nix { }) ];

  programs.git.settings.user = {
    email = "Arun.Udayashankar@tpicap.com";
    name = "Arun Udayashankar";
  };
}
