#!/usr/bin/env bash
# Check for available updates to custom node packages

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

for nix_file in "$SCRIPT_DIR"/*.nix; do
  [ -f "$nix_file" ] || continue

  pname=$(grep 'pname\s*=' "$nix_file" | head -1 | sed 's/.*"\(.*\)".*/\1/')
  current=$(grep 'version\s*=' "$nix_file" | head -1 | sed 's/.*"\(.*\)".*/\1/')

  if [ -z "$pname" ] || [ -z "$current" ]; then
    continue
  fi

  latest=$(npm view "$pname" version 2>/dev/null || echo "not found")

  if [ "$current" = "$latest" ]; then
    printf "  %s: %s (up to date)\n" "$pname" "$current"
  elif [ "$latest" = "not found" ]; then
    printf "  %s: %s (not on npm)\n" "$pname" "$current"
  else
    printf "* %s: %s -> %s\n" "$pname" "$current" "$latest"
  fi
done
