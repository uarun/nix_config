# Nix Configuration Flake

A declarative Nix flake-based configuration system for managing macOS (Darwin) and Linux systems using Nix Darwin and Home Manager.

## Overview

This project provides a unified, declarative approach to system configuration across multiple platforms:

- macOS (Darwin): System-level configuration via Nix Darwin
- Linux: User-level configuration via Home Manager
- Cross-platform: Shared modules and profiles work across both platforms
- Host-specific: Each machine can have its own configuration while sharing common modules

## Directory Structure

```
├── flake.nix                 #... Main flake definition with dynamic host discovery
├── flake.lock                #... Nix flake lock file
├── hosts/                    #... Host-specific configurations
│   ├── Melbourne/            #... Darwin host (macOS)
│   │   ├── config.nix        #... Host configuration (username, system, modules)
│   │   └── zshrc             #... Host-specific Zsh configuration
│   └── bifrost/              #... Linux host
│       └── config.nix        #... Host configuration
├── modules/                  #... Reusable configuration modules
│   ├── common.nix            #... Shared configuration for all systems
│   ├── nixpkgs.nix           #... Nixpkgs configuration
│   ├── primaryUser.nix       #... User account setup
│   ├── darwin/               #... macOS-specific modules
│   │   ├── core.nix          #... Core Darwin system configuration
│   │   ├── apps.nix          #... GUI applications
│   │   ├── homebrew.nix      #... Homebrew integration
│   │   └── preferences.nix   #... macOS system preferences
│   └── home-manager/         #... User environment modules
│       ├── default.nix       #... Home Manager entry point
│       ├── aliases.nix       #... Shell aliases
│       ├── dotfiles/         #... Dotfile templates
│       └── programs/         #... Program-specific configurations
│           ├── zsh.nix       #... Zsh shell configuration
│           ├── git.nix       #... Git configuration
│           ├── neovim.nix    #... Neovim editor setup
│           └── ...           #... Other program configs
└── profiles/                 #... Configuration profiles
    ├── personal.nix          #... Personal profile (Darwin)
    └── home-manager/         #... Home Manager profiles
        ├── personal.nix      #... Personal user profile
        └── work.nix          #... Work user profile
```

## Key Concepts

### Host Configurations

Each host (machine) gets its own directory under `hosts/` containing:
- `config.nix`: Defines username, system architecture, and extra modules
- Optional host-specific files (like `zshrc` for shell configuration)

The system automatically detects whether to create a Darwin or Home Manager configuration based on the `system` field ending in `-darwin` or `-linux`.

### Modules

- Common modules: Apply to all systems (fonts, basic packages)
- Darwin modules: macOS-specific (system preferences, GUI apps)
- Home Manager modules: User environment (shell, editors, CLI tools)

### Profiles

Profiles provide high-level configuration presets:
- Darwin profiles: System-level settings and applications
- Home Manager profiles: User-level applications and settings

## Usage

### Prerequisites

- Nix with flakes enabled
- For macOS: Xcode command line tools
- For Linux: A Linux distribution with Nix support

### Adding a New Host

1. **Create host directory:**
   ```bash
   mkdir hosts/YourHostName
   ```

2. **Create config.nix:**
   ```nix
   # hosts/YourHostName/config.nix
   {
     username = "yourusername";
     system = "aarch64-darwin";  # or "x86_64-linux"
     extraModules = [
       ../../profiles/home-manager/personal.nix
       # Add other modules as needed
     ];
   }
   ```

3. **Optional: Add host-specific configuration:**
   ```bash
   # Create hosts/YourHostName/zshrc for host-specific shell config
   echo "# Host-specific Zsh configuration" > hosts/YourHostName/zshrc
   ```

4. **Commit and build:**
   ```bash
   git add hosts/YourHostName/
   nix build .#$(id -un)@YourHostName:aarch64-darwin
   ```

### Building Configurations

#### macOS (Darwin)
```bash
# Build and switch (requires sudo)
sudo nix run nix-darwin -- switch --flake .#$(id -un)@$(hostname -s):aarch64-darwin

# Or build first, then switch
nix build .#$(id -un)@$(hostname -s):aarch64-darwin
./result/sw/bin/darwin-rebuild switch --flake .
```

Convenient aliases are available in the Zsh configuration:
- `dwswitch`: Switch Darwin configuration
- `dwupdate`: Update and switch Darwin configuration
- `dwclean`: Clean up old generations

#### Linux (Home Manager)
```bash
# Switch Home Manager configuration
home-manager switch --flake .#$(id -un)@$(hostname -s):x86_64-linux
```

Convenient alias:
- `hmswitch`: Switch Home Manager configuration

### Convenient Aliases

The Zsh configuration includes helpful aliases for common Nix operations:

**Darwin (macOS) aliases:**
- `dwswitch`: Switch Darwin configuration (`sudo darwin-rebuild switch --flake .#$(id -un)@$(hostname -s):aarch64-darwin`)
- `dwswitch_trace`: Switch with verbose tracing
- `dwupdate`: Update flake inputs and switch configuration
- `dwclean`: Clean up old system generations and optimize store
- `dwshowupdates`: Show changes between system generations

**Home Manager (Linux) aliases:**
- `hmswitch`: Switch Home Manager configuration (`home-manager switch --flake .#$(id -un)@$(hostname -s):x86_64-linux`)
- `hmclean`: Clean up old packages and optimize Nix store

### Available Configurations

List all available configurations:
```bash
# Darwin configurations
nix eval --impure '.#darwinConfigurations' --apply 'builtins.attrNames'

# Home Manager configurations
nix eval --impure '.#homeConfigurations' --apply 'builtins.attrNames'
```

### Current Hosts

- **Melbourne**: macOS (aarch64-darwin) - Personal development machine
- **bifrost**: Linux (x86_64-linux) - Work development environment

To build for your current machine, use: `.#$(id -un)@$(hostname -s):$(uname -m)-$(uname -s | tr '[:upper:]' '[:lower:]')`

## Configuration Examples

### Darwin Host (macOS)
```nix
# hosts/MyMacBook/config.nix
{
  username = "arun";
  system = "aarch64-darwin";
  extraModules = [
    ../../profiles/personal.nix          # Darwin system profile
    ../../modules/darwin/apps.nix        # GUI applications
  ];
}
```

### Linux Host
```nix
# hosts/MyLinuxBox/config.nix
{
  username = "arun";
  system = "x86_64-linux";
  extraModules = [
    ../../profiles/home-manager/personal.nix  # User profile
  ];
}
```

### Custom Profile
```nix
# profiles/home-manager/custom.nix
{ ... }: {
  programs.git.settings = {
    user.name = "Custom User";
    user.email = "custom@example.com";
  };
}
```

## Development

### Testing Changes
```bash
# Check flake for syntax errors
nix flake check

# Update flake inputs
nix flake update

# Clean up old generations
nix-collect-garbage
```

### Adding New Modules

1. Program module: Create `modules/home-manager/programs/newprogram.nix`
2. System module: Create `modules/darwin/newsystem.nix` or `modules/common.nix`
3. Import in appropriate default.nix: Add the new module to the imports list

## Troubleshooting

### Common Issues

- Path resolution errors: Ensure relative paths in config.nix use `../../` to reach the flake root
- Missing required fields: config.nix must have `username`, `system`, and `extraModules`
- Invalid system: System must end with `-darwin` or `-linux`
- Host-specific files: zshrc and other host files are automatically included if they exist

### Debug Commands
```bash
# Show available configurations
nix flake show

# Check flake evaluation
nix flake check

# Build with verbose output
nix build .#$(id -un)@$(hostname -s):aarch64-darwin --show-trace
```

## Contributing

1. Follow the existing directory structure
2. Test configurations on appropriate platforms
3. Update documentation for new features
4. Commit host-specific changes separately from shared modules
