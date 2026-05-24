#!/usr/bin/env bash
# Check for available updates to custom packages (npm- and GitHub-release-sourced)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

while IFS= read -r nix_file; do
  pname=$(grep 'pname\s*=' "$nix_file" | head -1 | sed 's/.*"\(.*\)".*/\1/')
  current=$(grep 'version\s*=' "$nix_file" | head -1 | sed 's/.*"\(.*\)".*/\1/')

  if [ -z "$pname" ] || [ -z "$current" ]; then
    continue
  fi

  if grep -q 'github\.com/.*/releases' "$nix_file"; then
    # GitHub releases source: derive owner/repo from the download URL in the file
    repo=$(grep -oE 'github\.com/[^/]+/[^/]+' "$nix_file" | head -1 | cut -d/ -f2-)
    latest=$(gh api "repos/$repo/releases/latest" --jq .tag_name 2>/dev/null || echo "not found")
    latest=${latest#v}   # normalize: some repos tag vX.Y.Z, others X.Y.Z
    origin="$repo"
  else
    # npm source: pname is the published package name
    latest=$(npm view "$pname" version 2>/dev/null || echo "not found")
    origin="npm"
  fi

  if [ "$current" = "$latest" ]; then
    printf "  %s: %s (up to date)\n" "$pname" "$current"
  elif [ "$latest" = "not found" ]; then
    printf "  %s: %s (no release info from %s)\n" "$pname" "$current" "$origin"
  else
    printf "* %s: %s -> %s\n" "$pname" "$current" "$latest"
  fi
done < <(find "$PACKAGES_DIR" -name '*.nix' | sort)
