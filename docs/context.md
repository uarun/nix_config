# Nix Configuration Project Context

## Project Overview

This is a comprehensive, declarative system configuration management project using Nix flakes. It provides unified configuration for macOS (via Nix Darwin) and Linux (via Home Manager) systems, with a focus on developer tooling, security, and maintainability.

**Key Characteristics:**
- **Unified Host Management**: Single directory structure for both Darwin and Linux configurations
- **Declarative**: All configurations are code, version-controlled, and reproducible
- **Modular**: Highly modular architecture with reusable components
- **Multi-platform**: Supports macOS (aarch64/x86_64) and Linux (x86_64)
- **Developer-focused**: Comprehensive development tools, security auditing, and productivity enhancements

## Core Technologies

### Nix Ecosystem
- **Nix Flakes**: Modern Nix dependency management and reproducible builds
- **Nix Darwin**: macOS system configuration management
- **Home Manager**: Cross-platform user environment management
- **Nixpkgs**: Package repository with 80,000+ packages

### Key Tools & Languages
- **Zsh**: Primary shell with extensive customization
- **Neovim**: Primary editor with comprehensive plugin ecosystem
- **Rust/Cargo**: Development tools including `cargo-audit` for security scanning
- **Git**: Version control with custom aliases and configurations

## Architecture Overview

### Configuration Hierarchy
```
flake.nix (entry point)
├── Dynamic host discovery from hosts/ directory
├── Configuration routing based on system type (*-darwin → Darwin, *-linux → Home Manager)
├── Modular imports from modules/ directory
└── Profile-based customization from profiles/ directory
```

### Three-Layer Architecture
1. **System Layer**: Darwin/Home Manager system configurations
2. **Module Layer**: Reusable configuration components
3. **Profile Layer**: Environment-specific customizations

## Directory Structure & Purpose

### Root Level
- `flake.nix`: Main entry point with dynamic host discovery and configuration routing
- `flake.lock`: Nix flake lockfile for reproducible builds
- `README.md`: User documentation and usage guide
- `.gitignore`: Git ignore patterns (includes `result`, `.DS_Store`)

### `hosts/` - Host-Specific Configurations
**Purpose**: Contains machine-specific configurations. Each subdirectory represents one logical host.

**Structure**:
```
hosts/{hostname}/
├── config.nix    # Host metadata (username, system, extraModules)
└── zshrc         # Optional: Host-specific Zsh configuration
```

**Current Hosts**:
- `Melbourne`: macOS (aarch64-darwin) - Primary development machine
- `bifrost`: Linux (x86_64-linux) - Work development environment

**Configuration Format**:
```nix
{
  username = "arun";
  system = "aarch64-darwin";  # or "x86_64-linux"
  extraModules = [
    ../../profiles/personal.nix
    ../../modules/darwin/apps.nix
  ];
}
```

### `modules/` - Reusable Configuration Components

#### `modules/common.nix` - Shared Configuration
- **Purpose**: Configurations applied to all systems (Darwin + Linux)
- **Contents**:
  - User account setup (`users.users`)
  - Home Manager bootstrapping for Darwin
  - System packages (neovim, git, coreutils, etc.)
  - Font installations (Nerd Fonts)
  - Environment variables and shell configuration

#### `modules/darwin/` - macOS-Specific Modules
- `core.nix`: Core Darwin system configuration (services, security, etc.)
- `apps.nix`: GUI application installations
- `homebrew.nix`: Homebrew package management configuration
- `preferences.nix`: macOS system preferences and defaults

#### `modules/home-manager/` - User Environment Modules
- `default.nix`: Main Home Manager configuration with packages and programs
- `aliases.nix`: Shell aliases (git, filesystem navigation)
- `programs/`: Individual program configurations
  - `zsh.nix`: Zsh shell with Powerlevel10k, plugins, and aliases
  - `git.nix`: Git configuration and aliases
  - `neovim.nix`: Neovim editor setup
  - Individual tool configs (bat, eza, fzf, etc.)

#### `modules/nixpkgs.nix` - Nixpkgs Configuration
- Package overrides and unfree package allowances
- Nix daemon configuration (GC, experimental features)

#### `modules/primaryUser.nix` - User Abstraction
- Provides `user` and `hmgr` options for user/home-manager configuration
- Abstracts away the difference between system users and Home Manager users

### `profiles/` - Environment Profiles

**Purpose**: Profiles provide contextual customizations to separate home vs work environments. Unlike modules which contain common configurations used everywhere, profiles contain settings that differ between contexts.

#### `profiles/personal.nix` - Darwin Personal Profile
- System-level personal customizations for macOS
- References Home Manager personal profile
- Used by Melbourne (home) host

#### `profiles/home-manager/` - User Environment Profiles
- `personal.nix`: Home environment customizations (personal git email/name, home-specific settings)
- `work.nix`: Work environment customizations (corporate git email, work-specific tools)
- Applied via `extraModules` in host configurations to customize the base modules

## Configuration Flow

### Host Discovery & Routing
1. `flake.nix` scans `hosts/` directory for subdirectories
2. Each host directory must contain `config.nix` with required fields
3. System type determines configuration type:
   - `*-darwin` → `darwinConfigurations`
   - `*-linux` → `homeConfigurations`

### Module Loading
1. Common modules loaded first (`common.nix`, `primaryUser.nix`, `nixpkgs.nix`)
2. Platform-specific modules loaded based on system type
3. Host-specific modules loaded from `config.nix`
4. Profile modules applied based on host configuration

### Special Configuration Handling
- **Darwin**: Home Manager integrated into system configuration
- **Linux**: Standalone Home Manager configurations
- **Hostname**: Passed to modules for host-specific file inclusion (e.g., `zshrc`)

## Key Configuration Patterns

### Dynamic Command Generation
Commands use shell variables for portability:
```bash
# Instead of hardcoded: .#arun@Melbourne:aarch64-darwin
# Use dynamic: .#$(id -un)@$(hostname -s):$(uname -m)-$(uname -s | tr '[:upper:]' '[:lower:]')
```

### Validation & Error Handling
- Runtime validation of required config fields
- System type validation (must be `*-darwin` or `*-linux`)
- Clear error messages for configuration mistakes

### Path Resolution
- Relative paths use `../` to navigate from host directories to project root
- Host-specific files referenced using hostname parameter in modules

## Common Workflows

### Adding a New Host
1. Create `hosts/NewHostName/config.nix` with required fields
2. Optionally add `hosts/NewHostName/zshrc` for host-specific shell config
3. Run `nix build .#$(id -un)@NewHostName:arch` to test
4. Commit changes

### Modifying User Environment
1. Edit relevant module in `modules/home-manager/programs/`
2. Or modify `modules/home-manager/default.nix` for packages/programs
3. Test with `home-manager build` (Linux) or Darwin rebuild

### System-Level Changes
1. Edit `modules/darwin/` files for macOS changes
2. Edit `modules/common.nix` for cross-platform changes
3. Test with `darwin-rebuild build` or `home-manager build`

## Gotchas & Important Notes

### Path Resolution Issues
- Host config paths use `../../` from `hosts/{name}/` to reach project root
- Import errors often indicate incorrect relative paths

### Home Manager Integration
- Darwin uses integrated Home Manager (part of system config)
- Linux uses standalone Home Manager configurations
- Both pass `hostname` parameter for host-specific files

### Git Management
- Only tracked files are visible to Nix flake evaluation
- Use `git add` before testing flake changes
- `.gitignore` excludes build artifacts (`result`, `.DS_Store`)

### Homebrew vs Nixpkgs
- Homebrew: For macOS-specific tools, GUI apps, and tools not in Nixpkgs
- Nixpkgs: Preferred for cross-platform CLI tools and reproducible builds

### Environment Variables
- Set in `~/.zshrc` for persistent environment setup
- Common: `LDFLAGS`, `CPPFLAGS`, `LIBRARY_PATH` for compilation

## Key Characteristics & Constraints

### User Management
- **Single User Focus**: Configuration primarily for user "arun" with work/personal profiles
- **No Multi-User Support**: The `audayashankar` user is for work environment separation, not multiple users
- **Profile-Based Environments**: Personal vs work configurations handled via profiles

### Host Naming
- **Machine Hostnames**: Host directory names match actual machine hostnames (e.g., `Melbourne`, `bifrost`)
- **No Logical Names**: Directory names directly correspond to `hostname -s` output

### Security & Secrets
- **No Secret Management**: No secrets, credentials, or sensitive data managed by this configuration
- **Git-Based Backup**: Relies on Git/GitHub for configuration backup and versioning
- **No External Dependencies**: No integrations with external services or APIs

### Development Practices
- **Simple Workflow**: No formal development processes, code review, or CI/CD
- **Unstable Branch**: Uses `nixpkgs-unstable` with infrequent updates
- **No Performance Optimizations**: Standard Nix usage without special caching or optimization strategies

## Recent Changes & Evolution

### Unified Host Configuration (Latest)
- Replaced hardcoded host lists with dynamic directory scanning
- Single `hosts/` structure for both Darwin and Linux
- Automatic routing based on system type

### Package Organization
- Reorganized Home Manager packages into logical groups
- Improved commenting and maintainability

### Tooling Additions
- Added `cargo-audit` via Homebrew for Rust security auditing
- Added `hmclean` alias for Home Manager maintenance

### Comment Standardization
- Consistent `#... ` comment style throughout codebase

## Dependencies & Requirements

### System Requirements
- **macOS**: Xcode Command Line Tools, Nix with flakes
- **Linux**: Nix with flakes, systemd (for some services)

### External Tools
- **Homebrew**: macOS package management (configured via Nix)
- **Rust/Cargo**: Development toolchain
- **Git**: Version control

### Development Environment
- **Editor**: Neovim with comprehensive plugin ecosystem
- **Shell**: Zsh with Powerlevel10k and extensive customization
- **Productivity**: Raycast, Obsidian, various development tools

## Maintenance & Development

### Testing Changes
```bash
# Syntax and evaluation check
nix flake check

# Build specific configuration
nix build .#$(id -un)@$(hostname -s):aarch64-darwin

# Update dependencies
nix flake update
```

### Code Organization Principles
1. **Modularity**: One concept per file
2. **Reusability**: Common configurations in shared modules
3. **Documentation**: Clear comments and README updates
4. **Consistency**: Standard comment style, naming conventions

### Adding New Features
1. **Programs**: Add to `modules/home-manager/programs/`
2. **System config**: Add to appropriate `modules/darwin/` or `modules/common.nix`
3. **Packages**: Add to relevant package lists
4. **Update docs**: Reflect changes in README and this context document

This context document should enable rapid understanding and effective contribution to this Nix configuration project.

## References & Documentation

### Nix Ecosystem
- [Nix Flakes Manual](https://nixos.org/manual/nix/stable/command-ref/new-cli/nix3-flake.html) - Official Nix flakes documentation
- [Nixpkgs Manual](https://nixos.org/manual/nixpkgs/stable/) - Nixpkgs package repository documentation

### Nix Darwin (macOS)
- [Nix Darwin Repository](https://github.com/LnL7/nix-darwin) - GitHub repository for Nix Darwin
- [Nix Darwin Options](https://daiderd.com/nix-darwin/manual/index.html) - Configuration options reference
- [Nix Darwin Manual](https://lnl7.github.io/nix-darwin/manual/index.html) - User manual

### Home Manager
- [Home Manager Repository](https://github.com/nix-community/home-manager) - GitHub repository
- [Home Manager Manual](https://nix-community.github.io/home-manager/) - User manual and configuration options
- [Home Manager Options](https://nix-community.github.io/home-manager/options.html) - Complete options reference

### Learning Resources
- [Nix Pills](https://nixos.org/guides/nix-pills/) - In-depth Nix tutorials
- [Zero to Nix](https://zero-to-nix.com/) - Beginner-friendly Nix introduction
- [NixOS Wiki](https://nixos.wiki/) - Community wiki with guides and examples</content>
<parameter name="filePath">/Users/arun/nix_config/docs/context.md