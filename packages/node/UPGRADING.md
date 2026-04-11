# Upgrading custom node packages

## Steps

1. Update `version` in the package `.nix` file
2. Replace both `hash` values with `lib.fakeHash`
3. Run `nix-build -E 'with import <nixpkgs> {}; callPackage ./packages/node/<name>.nix {}'`
4. Copy the correct source hash from the error, replace the first `lib.fakeHash`
5. Run the same build command again
6. Copy the correct pnpmDeps hash from the error, replace the second `lib.fakeHash`
7. Run the build a final time to verify it succeeds
8. Run `nix flake check` to confirm integration
9. Run `dwswitch` to install

## Notes

- If only the source changed (no dependency updates), the pnpmDeps hash may stay the same - try updating just the source hash first
- Tags follow the pattern `<pname>@<version>` (e.g., `ctx7@0.3.11`)
- Check available versions with `git ls-remote --tags <repo-url> | grep <pname>`
