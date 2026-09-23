{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  versionCheckHook,
}:
let
  version = "1.3.1";

  #... Prebuilt single-file binary (Bun-compiled) from Atlassian's CDN. The upstream
  #... installer (`bash <(curl -fsSL https://teamwork-graph.atlassian.com/cli/install)`)
  #... downloads exactly this asset into ~/.local/bin, so we skip the installer and
  #... fetch the asset directly. Hashes are the published SHA256SUMS values converted
  #... to SRI; see ./UPGRADING.md for the bump flow.
  baseUrl = "https://teamwork-graph.atlassian.com/cli";

  sources = {
    "aarch64-darwin" = {
      asset = "twg-darwin-arm64-v${version}";
      hash = "sha256-B8CCRN1+Q1gJ+TVvaaZF5HtkPngCTrd0yQK9rT3woaw=";
    };
    "x86_64-darwin" = {
      asset = "twg-darwin-x64-v${version}";
      hash = "sha256-dYh+1JWCafvneWbfWa2kLfO4X0suSPf4GJ97cnhEnEg=";
    };
    "aarch64-linux" = {
      asset = "twg-linux-arm64-v${version}";
      hash = "sha256-Cmz1v98mMIYzb+WI0Sjhtace/LvTqnjebfJoSctNLww=";
    };
    "x86_64-linux" = {
      asset = "twg-linux-x64-v${version}";
      hash = "sha256-8Vi8BgkxP+cWsZ2casoKjn+HoOJRzvDLdwKvj3QFqmM=";
    };
  };

  source =
    sources.${stdenv.hostPlatform.system}
      or (throw "twg: unsupported platform ${stdenv.hostPlatform.system}");
in
stdenv.mkDerivation {
  pname = "twg";
  inherit version;

  src = fetchurl {
    url = "${baseUrl}/${source.asset}";
    inherit (source) hash;
  };

  #... src is a bare executable, not an archive.
  dontUnpack = true;

  #... The JS bundle is appended to the executable and located by offset, so
  #... stdenv's default strip silently breaks it: the stripped binary still runs
  #... but falls through to the embedded Bun runtime, and `twg --version` then
  #... prints Bun's version instead of twg's. versionCheckHook below catches this.
  dontStrip = true;

  #... The Linux asset is dynamically linked against the host's glibc
  #... (libc/libm/libdl/libpthread + /lib64 interpreter), which does not exist on
  #... NixOS and is the wrong glibc elsewhere. Darwin assets need no patching.
  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];

  installPhase = ''
    runHook preInstall
    install -Dm755 $src $out/bin/twg
    runHook postInstall
  '';

  #... Run the installed binary so a successful build that cannot actually launch
  #... fails here rather than on first use.
  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgramArg = "--version";
  doInstallCheck = true;

  meta = {
    description = "Atlassian Teamwork Graph CLI (twg) - Rovo/Atlassian context for coding agents";
    homepage = "https://teamwork-graph.atlassian.com/cli";
    license = lib.licenses.unfree;
    mainProgram = "twg";
    platforms = builtins.attrNames sources;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
