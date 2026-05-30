{ pkgs, ... }: {
  programs.nushell = {
    enable = true;
    package = pkgs.nushell.overrideAttrs (_: {
      doCheck = false;  # Skip tests - they fail in nix sandbox due to permission issues
    });
  };
}
