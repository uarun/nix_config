# Nix Troubleshooting

## "object not found" errors during darwin-rebuild switch

**Symptoms:** Errors like:
```
error: looking up file '«github:...»/some/path': object not found - no match for id (...)
```
Affects various inputs (nixpkgs, home-manager, etc). Persists after `nix flake update` and cache clearing.

**Root cause:** Determinate Nix daemon caches corrupted/incomplete git objects. Standard user-level cache clearing is insufficient.

**Fix (run in order):**
```bash
# 1. Restart Determinate Nix daemon
sudo launchctl kickstart -k system/systems.determinate.nix-daemon

# 2. Clear all caches (daemon-level and user-level)
sudo rm -rf /nix/var/determinate
sudo rm -rf /var/root/.cache/nix
rm -rf ~/.cache/nix/tarball-cache-v2
rm -f ~/.cache/nix/fetcher-cache-v4.sqlite
rm -rf ~/.cache/nix/eval-cache-v6

# 3. Garbage collect broken store paths
nix store gc

# 4. Re-lock and rebuild
nix flake lock ~/nix_config --refresh
sudo darwin-rebuild switch --flake ~/nix_config/.#arun@Melbourne:aarch64-darwin
```

## Missing /run/current-system symlink after reboot

**Symptoms:** Ghostty or other apps fail because `/run/current-system/sw/bin/zsh` doesn't exist. User shell is set to this path.

**Root cause:** nix-darwin system activation lost after macOS reboot/update.

**Fix:** Re-run darwin-rebuild switch. If `darwin-rebuild` isn't on PATH, invoke directly:
```bash
sudo /nix/var/nix/profiles/system/sw/bin/darwin-rebuild switch --flake ~/nix_config/.#arun@Melbourne:aarch64-darwin
```
