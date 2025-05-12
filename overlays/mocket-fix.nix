# overlays/mocket-fix.nix
self: super: {
  python3 = super.python3.override {
    packageOverrides = python-self: python-super: {
      mocket = python-super.mocket.overridePythonAttrs (old: {
        doCheck = false;
      });
    };
  };
}
