{
  inputs,
  config,
  pkgs,
  ...
}:
let
  lib = inputs.lib-aggregate.lib;
in
{
  nixpkgs.config = {
    allowBroken = false;
    allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
      "vista-fonts"
    ];
  };

  nix = {
    extraOptions = ''
      keep-outputs = true
      keep-derivations = true
      experimental-features = nix-command flakes
    '';

    gc = {
      automatic = true;
      options = "--delete-older-than 14d";
    };

    # readOnlyStore = true;
    configureBuildUsers = true;               #... Manage nixbld group and users
  };
}
