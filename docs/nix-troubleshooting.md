# Nix Troubleshooting

## HTTP 401 errors during `hmswitch`

**Symptoms:** `hmswitch` reports many errors like:

```
error: file 'nar/...nar.zst' does not exist in binary cache 'https://cache.nixos.org'
error: unable to download 'https://download.savannah.gnu.org/...': HTTP error 401
```

This can look like a damaged Nix store or a cache outage. The NAR errors are often followed by a failed source build, such as the `acl` package.

**Root cause:** A corporate firewall returns a `401 Firewall Authentication` response for Nix cache and source-download requests. Nix treats the authenticated cache response as an unavailable NAR, then falls back to building from source, where the download fails with the same 401. This is a network-authentication problem, not a disk-capacity or Nix-store problem.

**Verify access:** Run this on the host where `hmswitch` runs, especially when connecting to a remote Linux host over SSH:

```bash
curl --config /dev/null \
  --cacert /etc/ssl/certs/ca-certificates.crt \
  -fsS https://cache.nixos.org/nix-cache-info
```

A successful request returns Nix cache metadata. HTTP 401 means the firewall session is not authenticated.

**Fix:** Open the cache URL in an approved browser on the same host/network path and complete the corporate firewall authentication:

```text
https://cache.nixos.org/nix-cache-info
```

If the host has no browser, connect it to the approved corporate VPN/network or ask IT to configure the authenticated proxy/allowlist for `cache.nixos.org` and `download.savannah.gnu.org`. Then verify the source endpoint and retry Home Manager:

```bash
curl --config /dev/null \
  --cacert /etc/ssl/certs/ca-certificates.crt \
  -fsS -o /dev/null \
  https://download.savannah.gnu.org/releases/acl/acl-2.4.0.tar.gz

hmswitch
```

Do not delete Nix store paths or add arbitrary substituters for this error. On hosts using the corporate CA setup, keep the normal bundle at `/etc/ssl/certs/ca-certificates.crt`; `/opt/certs/combined_certs.pem` contains the internal certificates and should not replace the normal public CA bundle by itself.

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
