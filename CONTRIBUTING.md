# Contributing / Development Workflow

## Dev Shell

This flake provides a dev shell with Nix linting and formatting tools. Enter it before making changes:

```bash
nix develop
```

This gives you:
- `deadnix` - finds unused variables, imports, and lambda patterns
- `statix` - catches Nix anti-patterns (empty patterns, repeated keys, collapsible let-in)
- `nixfmt` - canonical Nix formatter (RFC 166)

It also auto-installs a pre-commit hook on first entry.

## Pre-commit Hook

The dev shell installs a git pre-commit hook that runs `nixfmt --check`, `deadnix --fail` and `statix check` on staged `.nix` files. This prevents committing unformatted files or lint violations.

The hook is installed automatically when you enter `nix develop`. To reinstall manually:

```bash
nix develop  # re-entering the shell reinstalls the hook if it is missing or out of date
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

The flake exposes `nixfmt-tree` (nixfmt wrapped in treefmt) as its formatter,
so `nix fmt` is the canonical entry point. It walks the tree, honours
`.gitignore` - so build artefacts under `./result` are skipped - and accepts
individual paths:

```bash
nix fmt                       # format everything
nix fmt modules/common.nix    # format one file
```

Check formatting without leaving changes behind (treefmt writes, then fails if
anything changed):

```bash
nix fmt -- --ci
```

Without the flake (for example inside the pre-commit hook, which operates on
staged files only):

```bash
nixfmt --check $(find . -name '*.nix' -not -path './result/*')
```

Format all Nix files:

```bash
nixfmt $(find . -name '*.nix' -not -path './result/*')
```

## Accepted Warnings

`statix.toml` disables the statix `repeated_keys` (W20) lint for the whole repo, because statix 0.5.8 has no per-line ignore. Modules use the flat dotted style on purpose, for example `home.*` keys in `modules/home-manager/default.nix` and `system.*` keys in `modules/darwin/preferences.nix`. They are readable as-is and Nix merges them correctly.
