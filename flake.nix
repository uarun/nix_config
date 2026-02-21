{
  description = "Arun's Nix Configuration Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    #... Declarative configuration of user specific packages and dotfiles
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    #... MacOS system level settings
    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

  };

  outputs = {
    self,
    darwin,
    home-manager,
    ...
  } @ inputs:
  let
    lib = inputs.nixpkgs.lib;
    pkgsConfig = import ./modules/config.nix { inherit lib; };
    isDarwin = system: (builtins.elem system lib.platforms.darwin);
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
      hostname ? "",
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
        pkgs = import nixpkgs {
          inherit system;
          config = pkgsConfig;
        };
        extraSpecialArgs = {inherit self inputs nixpkgs hostname;};
        modules = baseModules ++ extraModules;
      };

  in
  let
    hostsDir = ./hosts;
    hostNames = builtins.attrNames (
      lib.filterAttrs (_: entryType: entryType == "directory") (builtins.readDir hostsDir)
    );

    #... Load and validate host configurations
    loadHostConfig = hostName:
      let
        configPath = hostsDir + "/${hostName}/config.nix";
        config =
          if builtins.pathExists configPath then
            import configPath
          else
            throw "Host ${hostName}: Missing required file ${toString configPath}";
      in
      let
        #... Validation
        requiredFields = [ "username" "system" "extraModules" ];
        missingFields = builtins.filter (field: !builtins.hasAttr field config) requiredFields;

        #... Validate system format
        systemValid = builtins.match ".*-(darwin|linux)" config.system != null;
      in
      if missingFields != [] then
        throw "Host ${hostName}: Missing required fields: ${builtins.concatStringsSep ", " missingFields}"
      else if !systemValid then
        throw "Host ${hostName}: Invalid system format '${config.system}'. Expected *-darwin or *-linux"
      else
        config // { hostname = hostName; };

    allHosts = builtins.map loadHostConfig hostNames;

    #... Separate by system type
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
          inherit (host) username system hostname extraModules;
        };
      }) linuxHosts
    );

    #... Per-host checks, grouped by system for `nix flake check`
    checks = builtins.foldl' (acc: host:
      let
        hostCheckName = "${host.username}@${host.hostname}";
        checkDrv = if builtins.match ".*-darwin" host.system != null then
          (mkDarwinConfig { inherit (host) system hostname extraModules; }).system
        else
          (mkHomeConfig { inherit (host) username system hostname extraModules; }).activationPackage;
      in
      acc // {
        "${host.system}" = (acc.${host.system} or {}) // {
          "${hostCheckName}" = checkDrv;
        };
      }
    ) {} allHosts;
  };
}
