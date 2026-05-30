{
  lib,
  stdenvNoCC,
  fetchurl,
}:
let
  version = "0.9.11";

  #... Prebuilt Rust binaries from GitHub releases (darwin only here).
  #... Note: ic-wasm tags have no leading "v". See ../node/UPGRADING.md for the bump flow.
  sources = {
    "aarch64-darwin" = {
      url = "https://github.com/dfinity/ic-wasm/releases/download/${version}/ic-wasm-aarch64-apple-darwin.tar.xz";
      hash = "sha256-LkfVFib1G4EaS6MdVVB2CVmP9LzLbFBnUJD93BaQRwM=";
    };
    "x86_64-darwin" = {
      url = "https://github.com/dfinity/ic-wasm/releases/download/${version}/ic-wasm-x86_64-apple-darwin.tar.xz";
      hash = "sha256-NiCqZWN0Eo2OqvFJ/3GS3lBhLQ4UCEYFL3OTF/qjYhk=";
    };
  };

  source =
    sources.${stdenvNoCC.hostPlatform.system}
      or (throw "ic-wasm: unsupported platform ${stdenvNoCC.hostPlatform.system}");
in
stdenvNoCC.mkDerivation {
  pname = "ic-wasm";
  inherit version;

  src = fetchurl { inherit (source) url hash; };

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall
    install -Dm755 */ic-wasm $out/bin/ic-wasm
    runHook postInstall
  '';

  meta = {
    description = "A tool for transforming Wasm canisters running on the Internet Computer";
    homepage = "https://github.com/dfinity/ic-wasm";
    license = lib.licenses.asl20;
    mainProgram = "ic-wasm";
    platforms = [
      "aarch64-darwin"
      "x86_64-darwin"
    ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
