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
     #"homebrew/core"
     #"homebrew/cask"
     # "homebrew/services"
     #"homebrew/bundle"
    ];

    #... List of Homebrew Formulae to install
    brews = [
       "cargo-audit"
       "opencode"
       "gemini-cli"
    ];

    #... List of Homebrew Casks to install
    casks = [
      { name = "brave-browser";            greedy = true; }
      { name = "caffeine";                 greedy = true; }
      { name = "citrix-workspace";         greedy = true; }
      { name = "claude-code";              greedy = true; }
      { name = "cursor";                   greedy = true; }
      { name = "discord";                  greedy = true; }
      { name = "disk-inventory-x";         greedy = true; }
      { name = "flux-app";                 greedy = true; }   # f.lux
      { name = "gpg-suite-no-mail";        greedy = true; }
      { name = "keepassxc";                greedy = true; }
      { name = "lm-studio";                greedy = true; }
      { name = "microsoft-teams";          greedy = true; }
      { name = "notion";                   greedy = true; }
      { name = "obsidian";                 greedy = true; }
      { name = "ollama-app";               greedy = true; }
      { name = "openmtp";                  greedy = true; }
      { name = "osaurus";                  greedy = true; }
      { name = "raycast";                  greedy = true; }
      { name = "superwhisper";             greedy = true; }
      { name = "syncthing-app";            greedy = true; } # TODO: Look into moving this to homemanager
      { name = "tor-browser";              greedy = true; }
      { name = "utm";                      greedy = true; }
      { name = "veracrypt";                greedy = true; }
      { name = "windsurf";                 greedy = true; }
      { name = "xquartz";                  greedy = true; }
      { name = "yubico-authenticator";     greedy = true; }
      { name = "yubico-yubikey-manager";   greedy = true; }
      { name = "zed";                      greedy = true; }
      { name = "zen";                      greedy = true; }
      { name = "zoom";                     greedy = true; }
    ];

    #... List of application to install from the offical Mac App Store (using mas)
    masApps = {
    };
  };
}
