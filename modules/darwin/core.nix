{
  inputs,
  pkgs,
  config,
  ...
}:
{
  #... Environment setup
  environment = {
    etc = {
      darwin.source = inputs.darwin.outPath;
    };

    #... Packages installed in system profile
    systemPackages = with pkgs; [
      darwin.libiconv
      whisper-cpp # ... CLI speech-to-text (whisper-cli)
      sox # ... CLI audio recorder (rec)
    ];

    systemPath = [ "${config.homebrew.prefix}/bin" ];
    pathsToLink = [ "/Applications" ];
  };

  security.pam.services.sudo_local = {
    touchIdAuth = true; # ... Enable sudo authentication with Touch ID
    reattach = true; # ... Make Touch ID work for sudo inside tmux/screen (pam_reattach)
  };

  #... Used for backwards compatibility, please read the changelog before changing.
  #... $ darwin-rebuild changelog
  system.stateVersion = 4;
}
