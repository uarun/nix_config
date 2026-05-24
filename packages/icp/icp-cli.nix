{
  lib,
  stdenvNoCC,
  fetchurl,
}:
let
  version = "0.2.7";

  #... Prebuilt Rust binaries from GitHub releases (darwin only here).
  #... Hashes come from the published *.tar.xz.sha256 files; see ../node/UPGRADING.md.
  sources = {
    "aarch64-darwin" = {
      url = "https://github.com/dfinity/icp-cli/releases/download/v${version}/icp-cli-aarch64-apple-darwin.tar.xz";
      hash = "sha256-J5YFalOpgwVYs1O3AsFocd2rMFr35ztkH5vNp5Xhz74=";
    };
    "x86_64-darwin" = {
      url = "https://github.com/dfinity/icp-cli/releases/download/v${version}/icp-cli-x86_64-apple-darwin.tar.xz";
      hash = "sha256-97lHcvwiNaNpnJib1TySNyLwJf40N1w1aHK1ie4Rvng=";
    };
  };

  source =
    sources.${stdenvNoCC.hostPlatform.system}
      or (throw "icp-cli: unsupported platform ${stdenvNoCC.hostPlatform.system}");
in
stdenvNoCC.mkDerivation {
  pname = "icp-cli";
  inherit version;

  src = fetchurl { inherit (source) url hash; };

  #... Tarball unpacks to icp-cli-<triple>/; stay at the parent so the glob is arch-agnostic.
  sourceRoot = ".";

  installPhase = ''
    runHook preInstall
    install -Dm755 */icp $out/bin/icp
    runHook postInstall
  '';

  meta = {
    description = "ICP CLI - command-line tool for building on the Internet Computer";
    homepage = "https://github.com/dfinity/icp-cli";
    license = lib.licenses.asl20;
    mainProgram = "icp";
    platforms = [ "aarch64-darwin" "x86_64-darwin" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
