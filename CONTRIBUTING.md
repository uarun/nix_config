# Contributing / Development Workflow

## Dev Shell

This flake provides a dev shell with Nix linting and formatting tools. Enter it before making changes:

```bash
nix develop
```

This gives you:
- `deadnix` — finds unused variables, imports, and lambda patterns
- `statix` — catches Nix anti-patterns (empty patterns, repeated keys, collapsible let-in)
- `nixfmt` — canonical Nix formatter (RFC 166)

It also auto-installs a pre-commit hook on first entry.

## Pre-commit Hook

The dev shell installs a git pre-commit hook that runs `deadnix` and `statix` on staged `.nix` files. This prevents committing lint violations.

The hook is installed automatically when you enter `nix develop`. To reinstall manually:

```bash
nix develop  # re-entering the shell reinstalls if missing
```

To skip the hook for a specific commit (e.g., WIP):

```bash
git commit --no-verify
```

## Linting

Run manually against the whole repo:

```bash
# Find unused code
deadnix .

# Find anti-patterns
statix check .

# Auto-fix what statix can
statix fix .
```

## Formatting

Check formatting without modifying files:

```bash
nixfmt --check $(find . -name '*.nix' -not -path './result/*')
```

Format all Nix files:

```bash
nixfmt $(find . -name '*.nix' -not -path './result/*')
```

Note: formatting is not enforced by the pre-commit hook (it's noisy on first run). Run it once to normalize, then it stays clean.

## Accepted Warnings

Two statix "repeated keys" warnings are intentionally suppressed:
- `modules/home-manager/default.nix` — `home.*` keys are grouped by concern (packages, session, files)
- `modules/darwin/preferences.nix` — `system.*` keys are grouped by domain (defaults, keyboard, user)

These are readable as-is and Nix merges them correctly.
