# Upgrading custom packages

Build a package on its own with the flake's locked nixpkgs (not `<nixpkgs>`, which resolves to the registry or channel nixpkgs and can print a different hash):

```bash
nix build --impure --expr 'let f = builtins.getFlake (toString ./.); in f.inputs.nixpkgs.legacyPackages.${builtins.currentSystem}.callPackage ./packages/node/<name>.nix {}'
```

Run it from the repo root. For unfree packages (twg), prefix it with `NIXPKGS_ALLOW_UNFREE=1`.

## pnpm packages (ctx7, excalidraw-edit)

These have a source `hash` plus a `pnpmDepsHashes` map with one hash per platform (`aarch64-darwin`, `x86_64-linux`). A build only reports the hash for the platform it runs on.

1. Update `version` in the package `.nix` file
2. Replace the source `hash` and both `pnpmDepsHashes` entries with `lib.fakeHash`
3. On the Mac, run the build command above
4. Copy the correct source hash from the error, replace the source `lib.fakeHash`
5. Run the same build command again
6. Copy the correct pnpmDeps hash from the error, replace the `aarch64-darwin` entry
7. Run the build a final time to verify it succeeds
8. Run `nix flake check` to confirm integration, then `dwswitch` to install
9. Commit and push, then on bifrost (or another x86_64-linux machine) pull the clone and run the same build command
10. Copy the pnpmDeps hash from the error into the `x86_64-linux` entry, rebuild to verify, commit and push
11. Run `hmswitch` on bifrost

Do not run `hmswitch` before step 10: it builds from the pushed flake and fails on the placeholder hash.

### Notes

- If only the source changed (no dependency updates), the pnpmDeps hashes may stay the same - try updating just the source hash first
- Tag formats differ per package, so check the `tag` line in the `.nix` file: ctx7 uses `ctx7@<version>`, excalidraw-edit uses `v<version>`
- Check available versions with `git ls-remote --tags <repo-url>`

## Prebuilt binaries (twg, ic-wasm, icp-cli)

These fetch one prebuilt asset per platform, listed in `sources`, each with its own `hash`.

1. Update `version` in the package `.nix` file. Check the release tag format in the asset URL: ic-wasm tags have no leading `v`, icp-cli tags do
2. Get each platform asset's SHA256 from the checksum file published with the release: twg lists them in the `SHA256SUMS` file next to the assets under `https://teamwork-graph.atlassian.com/cli`, icp-cli and ic-wasm publish a `<asset>.sha256` file next to each tarball on the GitHub release
3. Convert each hex hash to SRI and put it in that platform's `hash`:
   ```bash
   nix hash convert --hash-algo sha256 --to sri <hex>
   ```
   If a release has no checksum file, `nix store prefetch-file <url>` downloads the asset and prints its SRI hash
4. Run the build command above (path `./packages/atlassian/twg.nix` or `./packages/icp/<name>.nix`). Its install check runs the binary's version command
5. Run `nix flake check`, then `dwswitch` for ic-wasm and icp-cli. twg is installed by the work profile, so run `hmswitch` on bifrost after pushing
