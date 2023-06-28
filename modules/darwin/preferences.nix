{ ... }: {
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
      wvous-tl-corner = 4;                     #... hot corner action for top-left corner = show desktop
      static-only = false;                     #... show only open applications
      mineffect = "suck";                      #... One of "genie", "suck" or "scale" (Default is "genie")
    };

    NSGlobalDomain = {
      AppleShowAllExtensions = true;
      AppleKeyboardUIMode = 3;                 #... enable full keyboard control
      InitialKeyRepeat = 10;                   #... delay before repeating keystrokes
      KeyRepeat = 1;                           #... delay between repeated keystrokes when the key is held down

      AppleFontSmoothing = 2;                  #... heavy font smoothing
      NSScrollAnimationEnabled = true;         #... smooth scrolling
      AppleShowScrollBars = "Automatic";
    };

    #... Login Window settings
    loginwindow = {
      GuestEnabled = false;                    #... disable guest account
      SHOWFULLNAME = false;                    #... show name/password field instead of list of users, when false
      DisableConsoleAccess = true;             #... disables access to the console by typing “>console” for a username at the login window
    };

    #... Firewall settings
    alf = {
      globalstate = 1;                         #... 0 = disabled, 1 = enabled, 2 = block all incoming connections except for essential services
      loggingenabled = 0;                      #... logging of requests made to the firewall
      stealthenabled = 1;                      #... firewall drops incoming requests via ICMP
    };

    #... Trackpad settings
    trackpad = {
      ActuationStrength = 0;                   #... silent clicking = 0, default = 1
      Clicking = true;                         #... enable tap to click
      FirstClickThreshold = 1;                 #... firmness level, 0 = lightest, 2 = heaviest
      SecondClickThreshold = 1;                #... firmness level for force touch
      TrackpadRightClick = true;               #... two finger tap for right click
      TrackpadThreeFingerDrag = false;         #... three finger drag for space switching
    };

    #... Custom user preferences
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

  #... Keyboard settings
  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToControl = true;
  };
}
