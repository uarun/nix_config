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

  security.pam.enableSudoTouchIdAuth = true;  #... Enable sudo authentication with Touch ID

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

    #... Dock settings
    dock = {
      autohide = true;                 #... auto hide/show dock on hover
      autohide-delay = 0.0;            #... no delay in showing dock
      autohide-time-modifier = 0.2;    #... speed of dock animation
      expose-animation-duration = 0.2; 
      tilesize = 36;
      showhidden = true;
      show-recents = false;
      show-process-indicators = true;
      orientation = "bottom";          #... dock orientation/location
      wvous-tr-corner = 4;             #... hot corner action for top-right corner = show desktop
    };

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
