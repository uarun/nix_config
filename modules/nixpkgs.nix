{
  inputs,
  ...
}:
{
  nixpkgs.config = import ./config.nix { inherit (inputs.nixpkgs) lib; };

  nix.enable = false;
  nix = {
    extraOptions = ''
      keep-outputs = true
      keep-derivations = true
      experimental-features = nix-command flakes
    '';

    #gc = {
    #  automatic = true;
    #  options = "--delete-older-than 14d";
    #};

    # readOnlyStore = true;
  };
}
