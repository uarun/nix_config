{ ... }: {
  #... All things Homebrew go here
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
      "homebrew/cask"
    ];

    #... List of Homebrew Formulae to install
    brews = [
    ];

    #... List of Homebrew Casks to install
    casks = [
      "brave-browser"
      "citrix-workspace"
      "discord"
      "flux"                   # f.lux
      "keepassxc"
      "microsoft-teams"
      "notion"
      "obsidian"
      "raycast"
      "zoom"
    ];

    #... List of application to install from the offical Mac App Store (using mas)
    masApps = {
    };
  };
}
