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
    etc = { darwin.source = inputs.darwin.outPath; };

    #... Packages installed in system profile
    # systemPackages = [ ];
    systemPackages = with pkgs; [
      darwin.libiconv
      whisper-cpp                #... CLI speech-to-text (whisper-cli)
      sox                        #... CLI audio recorder (rec)
    ];

    systemPath = [ "/opt/homebrew/bin" ];
    pathsToLink = [ "/Applications" ];
  };

  homebrew.prefix = if isAarch64 || isAarch32
    then "/opt/homebrew"
    else "/usr/local";

  nix = {
    nixPath = ["darwin=/etc/${config.environment.etc.darwin.target}"];
    extraOptions = ''
      extra-platforms = x86_64-darwin aarch64-darwin
    '';
  };

  security.pam.services.sudo_local = {
    touchIdAuth = true; #... Enable sudo authentication with Touch ID
    reattach = true; #... Make Touch ID work for sudo inside tmux/screen (pam_reattach)
  };

  #... Used for backwards compatibility, please read the changelog before changing.
  #... $ darwin-rebuild changelog
  system.stateVersion = 4;
}
