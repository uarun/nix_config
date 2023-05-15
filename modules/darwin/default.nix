{ pkgs, ... }:
{
  services.nix-daemon.enable  = true;           #... Make sure the nix daemon always runs & manage the service
  nix.extraOptions = ''
    keep-outputs = true
    keep-derivations = true
    experimental-features = nix-command flakes
  '';

  programs.zsh.enable = true;

  environment = {
    shells = with pkgs; [ bashInteractive zsh ];
    loginShell = pkgs.zsh;
    systemPackages = with pkgs; [ cachix ];
    systemPath = [ "/opt/homebrew/bin" ];
    pathsToLink = [ "/Applications" ];
  };

  system.stateVersion = 4;  #... This is here for backwards compatibility, don't change

  system.defaults = {
    finder.AppleShowAllExtensions = true;
    finder.FXEnableExtensionChangeWarning = false;
    finder._FXShowPosixPathInTitle = true;
    finder.QuitMenuItem = true;
    finder.FXPreferredViewStyle = "Nlsv";           #... Change default finder view to List View
    finder.FXDefaultSearchScope = "SCcf";           #... Change default search scope to Current Folder
    finder.ShowPathbar   = true;
    finder.ShowStatusBar = true;

    LaunchServices.LSQuarantine = true;             #... Enable Quarantine for downloaded applications

    dock.autohide = true;

    NSGlobalDomain.AppleShowAllExtensions = true;
    NSGlobalDomain.InitialKeyRepeat = 15;
    NSGlobalDomain.KeyRepeat = 2;
  };

  homebrew = {
    enable = true;        #... nix-darwin to manage installing/updating/uprading Homebrew taps
    onActivation = {
      autoUpdate = false;
      upgrade = false;
      cleanup = "zap";    #... "uninstall" or "zap"
    };
    global.brewfile = true;

    #... List of Homebrew formula repositories to tap
    taps = [
    ];

    #... List of Homebrew Formulae to install
    brews = [
    ];

    #... List of Homebrew Casks to install
    casks = [ 
    ];

    #... List of application to install from the offical Mac App Store (using mas)
    masApps = {
    };
  };
}
