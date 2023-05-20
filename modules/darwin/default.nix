{ pkgs, ... }:
{
  services.nix-daemon.enable  = true;           #... Make sure the nix daemon always runs & manage the service
  nix.configureBuildUsers = true;               #... Manage nixbld group and users

  nix.extraOptions = ''
    keep-outputs = true
    keep-derivations = true
    experimental-features = nix-command flakes
  '';

  documentation.enable = true;    #... install documentation for systemPackages

  programs.zsh.enable = true;

  environment = {
    shells = with pkgs; [ bashInteractive zsh ];
    loginShell = pkgs.zsh;

    systemPath = [ "/opt/homebrew/bin" ];
    pathsToLink = [ "/Applications" ];

    systemPackages = with pkgs; [
      cachix
      curl
      git
    ];
  };

  #... Install Fonts
  fonts = {
    fontDir.enable = true;       #... If true, manually installed system fonts will be deleted !!
    fonts = with pkgs; [
      (nerdfonts.override {
        fonts = [
          "FiraCode"
          "Hasklig"
          "Inconsolata"
          "Iosevka"
          "IosevkaTerm"
          "JetBrainsMono"
          "Meslo"
          "Monofur"
          "NerdFontsSymbolsOnly"
          "SourceCodePro"
          "UbuntuMono"
          "VictorMono"
        ];
      })
      # vistafonts                #... Adding this mainly for Consolas (this needs allowUnfree to be set to true)
    ];
  };

  security.pam.enableSudoTouchIdAuth = true;  #... Enable sudo authentication with Touch ID

  #... MacOS System Preferences
  system.defaults = {

    #... Finder settings
    finder = {
      AppleShowAllExtensions = true;
      FXEnableExtensionChangeWarning = false;
      _FXShowPosixPathInTitle = true;
      QuitMenuItem = true;
      FXPreferredViewStyle = "Nlsv";           #... Change default finder view to List View
      FXDefaultSearchScope = "SCcf";           #... Change default search scope to Current Folder
      ShowPathbar   = true;
      ShowStatusBar = true;
    };

    LaunchServices.LSQuarantine = true;        #... Enable Quarantine for downloaded applications

    #... Dock settings
    dock = {
      autohide = true;                         #... auto hide/show dock on hover
      autohide-delay = 0.0;                    #... no delay in showing dock
      autohide-time-modifier = 0.2;            #... speed of dock animation
      expose-animation-duration = 0.2; 
      tilesize = 36;
      showhidden = true;
      show-recents = false;
      show-process-indicators = true;
      orientation = "bottom";                  #... dock orientation/location
      wvous-tr-corner = 4;                     #... hot corner action for top-right corner = show desktop
    };

    NSGlobalDomain = {
      AppleShowAllExtensions = true;
      AppleKeyboardUIMode = 3;                 #... enable full keyboard control
      InitialKeyRepeat = 15;
      KeyRepeat = 1;

      AppleFontSmoothing = 2;                  #... heavy font smoothing
      NSScrollAnimationEnabled = true;         #... smooth scrolling
      AppleShowScrollBars = "Automatic";
    };

    loginwindow = {
      GuestEnabled = false;                    #... disable guest account
      SHOWFULLNAME = false;                    #... show username instead of full name
      DisableConsoleAccess = true;             #... disables access to the console by typing “>console” for a username at the login window
    };

    #... Firewall settings
    alf = {
      globalstate = 1;                         #... 0 = disabled, 1 = enabled, 2 = block all incoming connections except for essential services
      loggingenabled = 0;                      #... logging of requests made to the firewall
      stealthenabled = 1;                      #... firewall drops incoming requests via ICMP
    };

    CustomUserPreferences = {
      "com.apple.AdLib" = { allowApplePersonalizedAdvertising = false; };
      "com.apple.SoftwareUpdate" = {
        AutomaticCheckEnabled = true;
        ScheduleFrequency = 1;         #... check for updates daily
        AutomaticDownload = 1;         #... download updates in the background
        CriticalUpdateInstall = 1;     #... install security updates
      };
      "com.apple.commerce".AutoUpdate = true;  #... auto-update apps
    };
  };

  #... All things Homebrew go here
  homebrew = import ./homebrew.nix pkgs;

  #... This is here for backwards compatibility, don't change
  system.stateVersion = 4;
}
