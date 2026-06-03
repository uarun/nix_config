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
stdenv.mkDerivation (finalAttrs: {
  pname = "excalidraw-edit";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "wh1le";
    repo = "excalidraw-edit";
    tag = "v${finalAttrs.version}";
    hash = "sha256-T7BMgWaPV4cbKPVAPXL++YkWxcp/8GkQxqJockazXlY=";
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
    hash = "sha256-8+jaPMnUB+nDq9+N25JgMYq6mHl4DBLyXRQYbSg6Kww=";
  };

  buildPhase = ''
    runHook preBuild
    pnpm run build
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/excalidraw-edit
    cp -r src $out/lib/excalidraw-edit/src
    cp package.json $out/lib/excalidraw-edit/

    # Copy runtime node_modules (pnpm virtual store)
    cp -r node_modules $out/lib/excalidraw-edit/node_modules

    mkdir -p $out/bin
    makeWrapper ${nodejs}/bin/node $out/bin/excalidraw-edit \
      --add-flags "$out/lib/excalidraw-edit/src/cli.js"

    runHook postInstall
  '';

  meta = {
    description = "Edit .excalidraw files locally in your browser. Like grip for Excalidraw.";
    homepage = "https://github.com/wh1le/excalidraw-edit";
    license = lib.licenses.mit;
    mainProgram = "excalidraw-edit";
    platforms = with lib.platforms; linux ++ darwin;
  };
})
