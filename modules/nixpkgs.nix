{
  inputs,
  ...
}:
{
  nixpkgs.config = import ./config.nix { inherit (inputs.nixpkgs) lib; };

  #... Determinate Nix owns /etc/nix/nix.conf; nix-darwin's nix settings are all
  #... gated behind `nix.enable`, so anything set here would be silently dropped.
  nix.enable = false;
}
