{
  description = "Arun's Nix Configuration Flake";

  inputs = {
    nixpkgs-stable.url   = "github:nixos/nixpkgs/nixos-22.11";  
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";  
    nixpkgs.url          = "github:nixos/nixpkgs/nixos-unstable";

    #... Declarative configuration of user speficic packages and dotfiles
    home-manager.url = "github:nix-community/home-manager/master";  # release-22.11
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    #... MacOS system level settings
    darwin.url = "github:lnl7/nix-darwin/master";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

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
    #... Function to generate a base darwin configuration with the specified hostname, overlays, and any extraModules applied
    mkDarwinConfig = {
      system ? "aarch64-darwin",
      nixpkgs ? inputs.nixpkgs,
      baseModules ? [
        home-manager.darwinModules.home-manager
        ./modules/darwin
      ],
      extraModules ? [],
    }:
    inputs.darwin.lib.darwinSystem {
      inherit system;
      modules = baseModules ++ extraModules;
      specialArgs = {inherit self inputs nixpkgs;};
    };

  in {
    darwinConfigurations = {
      Melbourne = mkDarwinConfig {
        system = "aarch64-darwin";
        extraModules = [
          ./profiles/personal.nix
          ./modules/darwin/apps.nix
        ];
      };
    };

    ### darwinConfigurations = let
    ###   system = "aarch64-darwin";    #... "x86_64-darwin" for intel based Macs
    ### in {
    ###   Melbourne = darwin.lib.darwinSystem {
    ###     pkgs = import nixpkgs { inherit system; };
    ###     modules = [
    ###       ./modules/darwin/default.nix
    ###       home-manager.darwinModules.home-manager {
    ###         home-manager = {
    ###           useGlobalPkgs   = true;
    ###           useUserPackages = true;
    ###           users.arun.imports = [ ./modules/home-manager/default.nix ];
    ###         };
    ###       }
    ###     ];
    ###   };
    ### };
  };
}
