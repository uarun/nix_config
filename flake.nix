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
  };

  outputs = inputs@{ nixpkgs, home-manager, darwin, ... }: {
    
    darwinConfigurations = let
      system = "aarch64-darwin";    #... "x86_64-darwin" for intel based Macs
    in {
      Adelaide = darwin.lib.darwinSystem {
        pkgs = import nixpkgs { inherit system; };
        modules = [
          ./modules/darwin/default.nix
          home-manager.darwinModules.home-manager {
            home-manager = {
              useGlobalPkgs   = true;
              useUserPackages = true;
              users.arun.imports = [ ./modules/home-manager/default.nix ];
            };
          }
        ];
      };
    };
  };
}
