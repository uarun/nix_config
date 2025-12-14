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

  system.primaryUser = "arun";             #... define the primary user name for the system (string: username used for user account, home-manager, and other user-specific configurations)

  #... Keyboard settings
  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToControl = true;
  };

  #... Firewall settings
  networking = {
    dns = [ "192.168.1.222" "9.9.9.9" "1.1.1.1" "8.8.8.8" ];  #... Custom DNS servers
    applicationFirewall = {
      enable = true;                         #... enable the application firewall (boolean: true to enable, false to disable, null for system default)
      enableStealthMode = true;              #... enable stealth mode to make the system less visible on the network (boolean: true to enable, false to disable, null for system default)
      blockAllIncoming = true;               #... block all incoming connections except explicitly allowed (boolean: true to block, false to allow, null for system default)
    };
  };
}
