{ lib, config, ... }:
let
  confContent = ''
    extra-sandbox-paths = /opt/certs/combined_certs.pem
  '';
in {
  home.activation.nixDaemonConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    confFile="/etc/nix/nix.conf"
    marker="extra-sandbox-paths = /opt/certs/combined_certs.pem"
    if [ -f "$confFile" ] && grep -qF "$marker" "$confFile"; then
      $VERBOSE_ECHO "nix daemon config: sandbox-paths already present"
    else
      echo "nix daemon config: adding extra-sandbox-paths (requires sudo)"
      printf '\n%s\n' ${lib.escapeShellArg confContent} | sudo tee -a "$confFile" >/dev/null
      sudo systemctl restart nix-daemon 2>/dev/null || true
    fi
  '';
}
