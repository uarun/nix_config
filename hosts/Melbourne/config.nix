{
  username = "arun";
  system = "aarch64-darwin";
  extraModules = [
    ../../profiles/personal.nix
    ../../modules/darwin/apps.nix
  ];
}