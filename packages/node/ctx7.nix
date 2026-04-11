{
  lib,
  stdenv,
  fetchFromGitHub,
  makeWrapper,
  nodejs,
  pnpm,
  pnpmConfigHook,
  fetchPnpmDeps,
}:
let
  tag-prefix = "ctx7";
in
stdenv.mkDerivation (finalAttrs: {
  pname = "ctx7";
  version = "0.3.11";

  src = fetchFromGitHub {
    owner = "upstash";
    repo = "context7";
    tag = "${tag-prefix}@${finalAttrs.version}";
    hash = "sha256-zhJDYjGop6qtpeLcuH/iOXJ1sIuAtl2yIV9NEvFuPDo=";
  };

  nativeBuildInputs = [
    nodejs
    pnpm
    pnpmConfigHook
    makeWrapper
  ];

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    fetcherVersion = 3;
    hash = "sha256-8RRHfCTZVC91T1Qx+ACCo2oG4ZwMNy5WYakCjmBhe3Q=";
  };

  buildPhase = ''
    runHook preBuild

    pnpm --filter ${tag-prefix} build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    pnpm --filter ${tag-prefix} \
         --offline \
         --config.inject-workspace-packages=true \
         deploy $out/lib/ctx7

    # Hoist transitive deps from pnpm virtual store so ESM resolution finds them
    for dir in $out/lib/ctx7/node_modules/.pnpm/node_modules/*/; do
      pkg=$(basename "$dir")
      if [ ! -e "$out/lib/ctx7/node_modules/$pkg" ]; then
        ln -s "$dir" "$out/lib/ctx7/node_modules/$pkg"
      fi
    done
    # Handle scoped packages
    for dir in $out/lib/ctx7/node_modules/.pnpm/node_modules/@*/; do
      scope=$(basename "$dir")
      mkdir -p "$out/lib/ctx7/node_modules/$scope"
      for pkg in "$dir"/*/; do
        name=$(basename "$pkg")
        if [ ! -e "$out/lib/ctx7/node_modules/$scope/$name" ]; then
          ln -s "$pkg" "$out/lib/ctx7/node_modules/$scope/$name"
        fi
      done
    done

    mkdir -p $out/bin
    makeWrapper ${nodejs}/bin/node $out/bin/ctx7 \
      --add-flags "$out/lib/ctx7/dist/index.js"

    runHook postInstall
  '';

  meta = {
    description = "Context7 CLI - Manage AI coding skills and documentation context";
    homepage = "https://context7.com/";
    license = lib.licenses.mit;
    mainProgram = "ctx7";
    platforms = with lib.platforms; linux ++ darwin;
  };
})
