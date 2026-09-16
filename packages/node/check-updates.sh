#!/usr/bin/env bash
# Check for available updates to custom packages (npm- and GitHub-sourced)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

#... Fail loudly on missing credentials rather than reporting every GitHub-sourced
#... package as "not found", which reads like "no new release".
if ! command -v gh >/dev/null 2>&1; then
  echo "error: gh is not installed; GitHub-sourced packages cannot be checked" >&2
  exit 1
fi
if ! gh auth status >/dev/null 2>&1 && [ -z "${GH_TOKEN:-}" ]; then
  echo "error: gh is not authenticated. Run 'gh auth login' or set GH_TOKEN." >&2
  exit 1
fi

while IFS= read -r nix_file; do
  pname=$(grep 'pname\s*=' "$nix_file" | head -1 | sed 's/.*"\(.*\)".*/\1/')
  current=$(grep 'version\s*=' "$nix_file" | head -1 | sed 's/.*"\(.*\)".*/\1/')

  if [ -z "$pname" ] || [ -z "$current" ]; then
    continue
  fi

  repo=""
  if grep -q 'github\.com/.*/releases' "$nix_file"; then
    #... Release-tarball source: derive owner/repo from the download URL.
    repo=$(grep -oE 'github\.com/[^/]+/[^/]+' "$nix_file" | head -1 | cut -d/ -f2-)
  elif grep -q 'fetchFromGitHub' "$nix_file"; then
    #... fetchFromGitHub source: no URL to scrape, so read the owner/repo attrs.
    owner=$(grep -oP 'owner\s*=\s*"\K[^"]+' "$nix_file" | head -1)
    name=$(grep -oP 'repo\s*=\s*"\K[^"]+' "$nix_file" | head -1)
    if [ -n "$owner" ] && [ -n "$name" ]; then
      repo="$owner/$name"
    fi
  fi

  if [ -n "$repo" ]; then
    origin="$repo"
    if ! err=$(gh api "repos/$repo/releases/latest" --jq .tag_name 2>&1 >/dev/null); then
      printf "! %s: %s (GitHub query failed: %s)\n" "$pname" "$current" "${err%%$'\n'*}"
      continue
    fi
    latest=$(gh api "repos/$repo/releases/latest" --jq .tag_name)
    #... Normalise tags: some repos use vX.Y.Z, monorepos use <pname>@X.Y.Z.
    latest=${latest#"$pname"@}
    latest=${latest#v}
  else
    #... npm source: pname is the published package name.
    origin="npm"
    if ! err=$(npm view "$pname" version 2>&1 >/dev/null); then
      printf "! %s: %s (npm query failed: %s)\n" "$pname" "$current" "$(echo "$err" | grep -m1 'npm error' || echo "unknown error")"
      continue
    fi
    latest=$(npm view "$pname" version)
  fi

  if [ -z "$latest" ]; then
    printf "! %s: %s (no version reported by %s)\n" "$pname" "$current" "$origin"
  elif [ "$current" = "$latest" ]; then
    printf "  %s: %s (up to date)\n" "$pname" "$current"
  else
    printf "* %s: %s -> %s\n" "$pname" "$current" "$latest"
  fi
done < <(find "$PACKAGES_DIR" -name '*.nix' | sort)
