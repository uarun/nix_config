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
    defaultSystems = [ "aarch64-linux" "aarch64-darwin" "x86_64-darwin" "x86_64-linux" ];

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
        pkgs = import nixpkgs { inherit system; };
        extraSpecialArgs = {inherit self inputs nixpkgs;};
        modules = baseModules ++ extraModules;
      };

    mkChecks = {
      arch,
      os,
      username ? "arun",
    }: {
      "${arch}-${os}" = {
        "${username}_${os}" =
          if os == "darwin"
          then
            self.darwinConfigurations
            ."${username}@${arch}-${os}"
            .config
            .system
            .build
            .toplevel
          else
            builtins.derivation {                      ##... Dummy derivation until we implement a NixOS derivation
              name = "NixOS_NotImplemented";
              builder = "true";
              system  = "${arch}-${os}";
            };

        "${username}_home" =
          self.homeConfigurations."${username}@${arch}-${os}".activationPackage;
      };
    };

  in {

    #... MacOS Configurations
    darwinConfigurations = {
      "arun@aarch64-darwin" = mkDarwinConfig {
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
        extraModules = [ ./profiles/home-manager/work.nix ];
      };

      "arun@x86_64-linux" = mkHomeConfig {
        username = "arun";
        system   = "x86_64-linux";
        extraModules = [ ./profiles/home-manager/personal.nix ];
      };

      "arun@aarch64-darwin" = mkHomeConfig {
        username = "arun";
        system   = "aarch64-darwin";
        extraModules = [ ./profiles/home-manager/personal.nix ];
      };
    };

    checks = {}
      // (mkChecks { arch = "aarch64"; os = "darwin"; username = "arun"; })
      // (mkChecks { arch = "x86_64";  os = "linux";  username = "audayashankar"; });
  };
}
