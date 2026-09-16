{ pkgs, ... }:
{
  programs.tealdeer = {
    enable = true;
    settings = {
      display = {
        compact = false;
        use_pager = false; # ... colors are messed up in the pager, else we would set this to true
      };
      updates = {
        #... Tealdeer links rustls + webpki-roots, so it trusts only Mozilla's CA
        #... bundle and ignores SSL_CERT_FILE. Behind the corporate proxy on Linux
        #... hosts `tldr --update` always fails with InvalidCertificate(UnknownIssuer),
        #... so keep auto-update on Darwin and use `tldr-update` (curl-based) elsewhere.
        auto_update = pkgs.stdenv.hostPlatform.isDarwin;
      };
    };
  };

  #... curl respects the system CA bundle, so this works where `tldr --update` cannot.
  home.packages = [
    (pkgs.writeShellApplication {
      name = "tldr-update";
      runtimeInputs = with pkgs; [
        curl
        unzip
      ];
      text = builtins.readFile ../../../scripts/update-tldr-cache.sh;
    })
  ];
}
