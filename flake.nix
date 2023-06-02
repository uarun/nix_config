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
    isDarwin = system: (builtins.elem system inputs.nixpkgs.lib.platforms.darwin);
    homePrefix = system: if isDarwin system then "/Users" else "/home";

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
        extraSpecialArgs = {inherit self inputs nixpkgs;};
        modules = baseModules ++ extraModules;
      };

  in {

    #... MacOS Configurations
    darwinConfigurations = {
      Melbourne = mkDarwinConfig {
        system = "aarch64-darwin";
        extraModules = [
          ./profiles/personal.nix
          ./modules/darwin/apps.nix
        ];
      };
    };

    #... Home Manager Configurations (for non-NixOS Linux installations)
    homeConfigurations = {
      "audayashankar@x86_64-linux" = mkHomeConfig {
        username = "audayashankar";
        system   = "x86_64-linux";
        extraModules = [ ./profile/home-manager/work.nix ];
      };
    };

    #... NixOS Configurations
    nixosConfigurations = {
    };

  };
}
