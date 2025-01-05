{ ... }: {
  #... All things Homebrew go here
  homebrew = {
    enable = true;        #... nix-darwin to manage installing/updating/uprading Homebrew taps
    onActivation = {
      autoUpdate = false;
      upgrade = true;
      cleanup = "zap";    #... "uninstall" or "zap"
    };
    global = {
      brewfile = true;
      autoUpdate = false;
    };

    #... List of Homebrew formula repositories to tap
    taps = [
      # "homebrew/core"
      # "homebrew/bundle"
      # "homebrew/cask"
      # "homebrew/services"
    ];

    #... List of Homebrew Formulae to install
    brews = [
    ];

    #... List of Homebrew Casks to install
    casks = [
      { name = "brave-browser";            greedy = true; }
      { name = "caffeine";                 greedy = true; }
      { name = "citrix-workspace";         greedy = true; }
      { name = "discord";                  greedy = true; }
      { name = "disk-inventory-x";         greedy = true; }
      { name = "docker";                   greedy = true; }
      { name = "flux";                     greedy = true; }   # f.lux
      { name = "gpg-suite-no-mail";        greedy = true; }
      { name = "keepassxc";                greedy = true; }
      { name = "lm-studio";                greedy = true; }
      { name = "microsoft-teams";          greedy = true; }
      { name = "notion";                   greedy = true; }
      { name = "obsidian";                 greedy = true; }
      { name = "openmtp";                  greedy = true; }
      { name = "raycast";                  greedy = true; }
      { name = "syncthing";                greedy = true; } # TODO: Look into moving this to homemanager
      { name = "tor-browser";              greedy = true; }
      { name = "utm";                      greedy = true; }
      { name = "veracrypt";                greedy = true; }
      { name = "xquartz";                  greedy = true; }
      { name = "yubico-authenticator";     greedy = true; }
      { name = "yubico-yubikey-manager";   greedy = true; }
      { name = "zed";                      greedy = true; }
      { name = "zoom";                     greedy = true; }
    ];

    #... List of application to install from the offical Mac App Store (using mas)
    masApps = {
    };
  };
}
