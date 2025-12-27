{
  description = "Arun's Nix Configuration Flake";

  inputs = {
    nixpkgs-stable.url   = "github:nixos/nixpkgs/nixos-23.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs.url          = "github:nixos/nixpkgs/nixos-unstable";

    #... Declarative configuration of user specific packages and dotfiles
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs-unstable";

    #... MacOS system level settings
    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs-unstable";

    lib-aggregate.url = "github:nix-community/lib-aggregate";    #... Aggregate of nix libs that do not depend on nixpkgs
    flake-utils.url   = "github:numtide/flake-utils";

  };

  outputs = {
    self,
    darwin,
    home-manager,
    ...
  } @ inputs:
  let
    isDarwin = system: (builtins.elem system inputs.nixpkgs.lib.platforms.darwin);
    homePrefix = system: if isDarwin system then "/Users" else "/home";
    defaultSystems = [ "aarch64-linux" "aarch64-darwin" "x86_64-darwin" "x86_64-linux" ];

    #... Function to generate a base darwin configuration with the specified hostname, overlays, and any extraModules applied
    mkDarwinConfig = {
      system ? "aarch64-darwin",
      nixpkgs ? inputs.nixpkgs,
      hostname ? "",
      baseModules ? [
        home-manager.darwinModules.home-manager
        ./modules/darwin
      ],
      extraModules ? [],
    }:
      inputs.darwin.lib.darwinSystem {
        inherit system;
        modules = baseModules ++ extraModules;
        specialArgs = {inherit self inputs nixpkgs hostname;};
      };

    #... Function to generate home manager configuration usable on any unix system
    mkHomeConfig = {
      username,
      system  ? "x86_64-linux",
      nixpkgs ? inputs.nixpkgs,
      baseModules ? [
        ./modules/home-manager
        {
          home = {
            inherit username;
            homeDirectory = "${homePrefix system}/${username}";
            sessionVariables = { };
          };
        }
      ],
      extraModules ? [],
    }:
      inputs.home-manager.lib.homeManagerConfiguration rec {
        pkgs = import nixpkgs { inherit system; };
        extraSpecialArgs = {inherit self inputs nixpkgs;};
        modules = baseModules ++ extraModules;
      };

  in
  let
    hostsDir = ./hosts;
    hostNames = builtins.attrNames (builtins.readDir hostsDir);

    # Load and validate host configurations
    loadHostConfig = hostName:
      let
        configPath = hostsDir + "/${hostName}/config.nix";
        config = import configPath;

        # Validation
        requiredFields = ["username" "system" "extraModules"];
        missingFields = builtins.filter (field: !config ? field) requiredFields;

        # Validate system format
        systemValid = builtins.match ".*-(darwin|linux)" config.system != null;
      in
        if missingFields != [] then
          throw "Host ${hostName}: Missing required fields: ${builtins.concatStringsSep ", " missingFields}"
        else if !systemValid then
          throw "Host ${hostName}: Invalid system format '${config.system}'. Expected *-darwin or *-linux"
        else
          config // { hostname = hostName; };

    allHosts = builtins.map loadHostConfig hostNames;

    # Separate by system type
    darwinHosts = builtins.filter (host: builtins.match ".*-darwin" host.system != null) allHosts;
    linuxHosts = builtins.filter (host: builtins.match ".*-linux" host.system != null) allHosts;

  in {

    #... MacOS Configurations
    darwinConfigurations = builtins.listToAttrs (
      map (host: {
        name = "${host.username}@${host.hostname}:${host.system}";
        value = mkDarwinConfig {
          inherit (host) system hostname extraModules;
        };
      }) darwinHosts
    );

    #... Linux Home Manager Configurations
    homeConfigurations = builtins.listToAttrs (
      map (host: {
        name = "${host.username}@${host.hostname}:${host.system}";
        value = mkHomeConfig {
          inherit (host) username system extraModules;
        };
      }) linuxHosts
    );

    # Checks removed for now
    checks = {};
  };
}
