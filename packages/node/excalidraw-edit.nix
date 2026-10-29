{
  lib,
  stdenv,
  fetchFromGitHub,
  makeWrapper,
  nodejs,
  pnpm,
  pnpmConfigHook,
  fetchPnpmDeps,
  versionCheckHook,
}:
let
  pnpmDepsHashes = {
    aarch64-darwin = "sha256-XdSI3/WF0X2rCdjYKzloUx3Maq0BjksXB3r/f086U5c=";
    x86_64-linux = "sha256-453U5BxHi0PbqMfwwCiOrdf2rBpjUPNi+8y439/8vMU=";
  };
in
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
    fetcherVersion = 4;
    #... The fetched pnpm tree differs per platform, so each one has its own hash.
    hash =
      pnpmDepsHashes.${stdenv.hostPlatform.system}
        or (throw "excalidraw-edit: no pnpm deps hash for ${stdenv.hostPlatform.system}");
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

  #... Run the installed binary so a successful build that cannot actually launch
  #... fails here rather than on first use.
  nativeInstallCheckInputs = [ versionCheckHook ];
  doInstallCheck = true;

  meta = {
    description = "Edit .excalidraw files locally in your browser. Like grip for Excalidraw.";
    homepage = "https://github.com/wh1le/excalidraw-edit";
    license = lib.licenses.mit;
    mainProgram = "excalidraw-edit";
    platforms = with lib.platforms; linux ++ darwin;
  };
})
