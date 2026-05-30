{
  lib,
  stdenvNoCC,
  fetchurl,
  makeWrapper,
  nodejs,
}:
let
  version = "2.13.2";

  #... mops ships a self-contained, bun-bundled standalone inside its npm tarball
  #... (package/bundle/cli.tgz - the same artifact the official curl|bash installer uses).
  #... Everything is inlined except @napi-rs/lzma (a native addon, kept external by the
  #... bundle), which we drop in alongside so xz decompression of the moc toolchain works.
  #... moc itself is still fetched at runtime by `mops toolchain` into a user cache.
  lzmaVersion = "1.4.5";
  lzmaTargets = {
    "aarch64-darwin" = {
      pkg = "lzma-darwin-arm64";
      node = "lzma.darwin-arm64.node";
      hash = "sha256-giEIRyYZPYJWk5rvFsStXCL72KsYDZEdlCyfTt8IAk0=";
    };
    "x86_64-darwin" = {
      pkg = "lzma-darwin-x64";
      node = "lzma.darwin-x64.node";
      hash = "sha256-FYu73Vwe/8wV1yh8LnKevoH3SFbYJOtvQvYE+17b3P4=";
    };
  };

  lzmaTarget =
    lzmaTargets.${stdenvNoCC.hostPlatform.system}
      or (throw "ic-mops: unsupported platform ${stdenvNoCC.hostPlatform.system}");

  lzmaJs = fetchurl {
    url = "https://registry.npmjs.org/@napi-rs/lzma/-/lzma-${lzmaVersion}.tgz";
    hash = "sha256-vn3CegqzaNB44q5zRW/ujhIRHWAlnB3jEj6+GE9NCLo=";
  };

  lzmaNative = fetchurl {
    url = "https://registry.npmjs.org/@napi-rs/${lzmaTarget.pkg}/-/${lzmaTarget.pkg}-${lzmaVersion}.tgz";
    inherit (lzmaTarget) hash;
  };
in
stdenvNoCC.mkDerivation {
  pname = "ic-mops";
  inherit version;

  src = fetchurl {
    url = "https://registry.npmjs.org/ic-mops/-/ic-mops-${version}.tgz";
    hash = "sha256-ZNP54mo0dzgiQ/Oi8mMGWtmoBUMCDIizweAMG8C+7bY=";
  };

  nativeBuildInputs = [ makeWrapper ];

  #... npm tarball unpacks to ./package; cwd is there during installPhase.
  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/mops
    tar xzf bundle/cli.tgz -C $out/lib/mops

    #... Restore the externalized @napi-rs/lzma dep next to the bundled cli.js so
    #... `import ... from "@napi-rs/lzma/xz"` resolves, with its native .node inlined.
    lzmadir=$out/lib/mops/bundle/node_modules/@napi-rs/lzma
    mkdir -p "$lzmadir"
    tar xzf ${lzmaJs} -C "$lzmadir" --strip-components=1
    tar xzf ${lzmaNative} -C "$lzmadir" --strip-components=1 package/${lzmaTarget.node}

    makeWrapper ${lib.getExe nodejs} $out/bin/mops \
      --add-flags "$out/lib/mops/bundle/cli.js"
    ln -s $out/bin/mops $out/bin/ic-mops

    runHook postInstall
  '';

  meta = {
    description = "Motoko package manager (mops) for the Internet Computer";
    homepage = "https://mops.one/";
    license = lib.licenses.mit;
    mainProgram = "mops";
    platforms = [
      "aarch64-darwin"
      "x86_64-darwin"
    ];
    sourceProvenance = [ lib.sourceTypes.binaryBytecode ];
  };
}
