{ ... }:
{
  imports = [
    ../common.nix
    ./core.nix
    ./homebrew.nix
    ./preferences.nix
    ./services.nix
  ];
}
