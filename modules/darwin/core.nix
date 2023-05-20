{
  inputs,
  config,
  pkgs,
  ...
}: let
  inherit (pkgs.stdenvNoCC) isAarch64 isAarch32;
in {
  #... Environment setup
  environment = {
    loginShell = pkgs.zsh;
    #... Packages installed in system profile
    # systemPackages = [ ];

    systemPath = [ "/opt/homebrew/bin" ];
    pathsToLink = [ "/Applications" ];
  };

  homebrew.brewPrefix = if isAarch64 || isAarch32 
    then "/opt/homebrew/bin" 
    else "/usr/local/bin";

  services.nix-daemon.enable = true;                   #... Auto upgrade nix package and the daemon service.
  nix.configureBuildUsers = true;                      #... Auto manage nixbld users with nix darwin

  security.pam.enableSudoTouchIdAuth = true;           #... Enable sudo authentication with Touch ID

  #... Used for backwards compatibility, please read the changelog before changing.
  #... $ darwin-rebuild changelog
  system.stateVersion = 4;
}
