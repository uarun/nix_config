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

  outputs =
    {
      self,
      home-manager,
      ...
    }@inputs:
    let
      inherit (inputs.nixpkgs) lib;
      pkgsConfig = import ./modules/config.nix { inherit lib; };
      isDarwin = system: (builtins.elem system lib.platforms.darwin);
      homePrefix = system: if isDarwin system then "/Users" else "/home";
      defaultSystems = [
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64-linux"
      ];

      #... Function to generate a base darwin configuration with the specified username, hostname, and any extraModules applied
      mkDarwinConfig =
        {
          username,
          system ? "aarch64-darwin",
          hostname ? "",
          baseModules ? [
            home-manager.darwinModules.home-manager
            ./modules/darwin
            {
              user.name = username;
              system.primaryUser = username;
            }
          ],
          extraModules ? [ ],
        }:
        inputs.darwin.lib.darwinSystem {
          inherit system;
          modules = baseModules ++ extraModules;
          specialArgs = {
            inherit
              self
              inputs
              hostname
              ;
          };
        };

      #... Function to generate home manager configuration usable on any unix system
      mkHomeConfig =
        {
          username,
          system ? "x86_64-linux",
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
          extraModules ? [ ],
        }:
        inputs.home-manager.lib.homeManagerConfiguration {
          pkgs = import inputs.nixpkgs {
            inherit system;
            config = pkgsConfig;
          };
          extraSpecialArgs = {
            inherit
              self
              inputs
              hostname
              ;
          };
          modules = baseModules ++ extraModules;
        };

      hostsDir = ./hosts;
      hostNames = builtins.attrNames (
        lib.filterAttrs (_: entryType: entryType == "directory") (builtins.readDir hostsDir)
      );

      #... Load and validate host configurations
      loadHostConfig =
        hostName:
        let
          configPath = hostsDir + "/${hostName}/config.nix";
          config =
            if builtins.pathExists configPath then
              import configPath
            else
              throw "Host ${hostName}: Missing required file ${toString configPath}";

          #... Validation
          requiredFields = [
            "username"
            "system"
            "extraModules"
          ];
          missingFields = builtins.filter (field: !builtins.hasAttr field config) requiredFields;

          #... Validate system format
          systemValid = builtins.match ".*-(darwin|linux)" config.system != null;
        in
        if missingFields != [ ] then
          throw "Host ${hostName}: Missing required fields: ${builtins.concatStringsSep ", " missingFields}"
        else if !systemValid then
          throw "Host ${hostName}: Invalid system format '${config.system}'. Expected *-darwin or *-linux"
        else
          config // { hostname = hostName; };

      allHosts = builtins.map loadHostConfig hostNames;

      #... Separate by system type
      darwinHosts = builtins.filter (host: builtins.match ".*-darwin" host.system != null) allHosts;
      linuxHosts = builtins.filter (host: builtins.match ".*-linux" host.system != null) allHosts;

      #... Output attribute name shared by the configurations and the checks
      hostOutputName = host: "${host.username}@${host.hostname}:${host.system}";

    in
    {

      #... MacOS Configurations
      darwinConfigurations = builtins.listToAttrs (
        map (host: {
          name = hostOutputName host;
          value = mkDarwinConfig {
            inherit (host)
              username
              system
              hostname
              extraModules
              ;
          };
        }) darwinHosts
      );

      #... Linux Home Manager Configurations
      homeConfigurations = builtins.listToAttrs (
        map (host: {
          name = hostOutputName host;
          value = mkHomeConfig {
            inherit (host)
              username
              system
              hostname
              extraModules
              ;
          };
        }) linuxHosts
      );

      #... `nix fmt` entry point. nixfmt-tree wraps nixfmt in treefmt, which walks
      #... directories and honours .gitignore, so build artefacts under ./result are
      #... skipped. Bare `nixfmt .` would descend into them.
      formatter = builtins.listToAttrs (
        map (system: {
          name = system;
          value = (import inputs.nixpkgs { inherit system; }).nixfmt-tree;
        }) defaultSystems
      );

      #... Dev shell with linting tools for this config
      devShells = builtins.listToAttrs (
        map (system: {
          name = system;
          value.default =
            let
              pkgs = import inputs.nixpkgs { inherit system; };
              preCommitHook = pkgs.writeText "pre-commit" ''
                #!/usr/bin/env bash
                # nix-lint pre-commit hook
                set -euo pipefail

                staged=$(git diff --cached --name-only --diff-filter=ACM -- '*.nix')
                [ -z "$staged" ] && exit 0

                if ! command -v deadnix &>/dev/null; then
                  deadnix() { nix run nixpkgs#deadnix -- "$@"; }
                  statix() { nix run nixpkgs#statix -- "$@"; }
                  nixfmt() { nix run nixpkgs#nixfmt -- "$@"; }
                fi

                echo "Running nixfmt..."
                nixfmt --check $staged

                echo "Running deadnix..."
                deadnix --fail $staged

                echo "Running statix..."
                statix check $staged
              '';
            in
            pkgs.mkShell {
              packages = with pkgs; [
                nixfmt
                statix
                deadnix
              ];
              #... Compare contents, so edits to the hook reach existing clones too.
              shellHook = ''
                if ! cmp -s ${preCommitHook} .git/hooks/pre-commit; then
                  echo "Installing pre-commit hook..."
                  install -m 755 ${preCommitHook} .git/hooks/pre-commit
                fi
              '';
            };
        }) defaultSystems
      );

      #... Per-host checks, grouped by system for `nix flake check`
      checks = builtins.foldl' (
        acc: host:
        let
          hostCheckName = "${host.username}@${host.hostname}";
          checkDrv =
            if builtins.match ".*-darwin" host.system != null then
              self.darwinConfigurations.${hostOutputName host}.system
            else
              self.homeConfigurations.${hostOutputName host}.activationPackage;
        in
        acc
        // {
          "${host.system}" = (acc.${host.system} or { }) // {
            "${hostCheckName}" = checkDrv;
          };
        }
      ) { } allHosts;
    };
}
