# Fix: Determinate Nix incomplete git object fetch

## Problem
`nix flake update` fetched nixpkgs rev `00c21e4` with missing git objects → `object not found` error for `oniguruma/package.nix`.

## Steps
1. `rm -f ~/.cache/nix/fetcher-cache-v4.sqlite` — clear fetcher cache
2. `rm -rf ~/.cache/nix/eval-cache-v6` — clear eval cache
3. `nix flake update nixpkgs` — re-fetch fresh
4. Test build: `nix build` or `darwin-rebuild switch --flake .`
5. If still fails → `nix store gc`, clear entire `~/.cache/nix/`, retry

## Verification
- `nix flake show` should succeed without object errors
- Build/switch should complete
