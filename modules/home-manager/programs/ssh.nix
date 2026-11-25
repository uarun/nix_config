{
  config,
  lib,
  pkgs,
  ...
}:
let
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
  home = config.home.homeDirectory;

  #... On macOS the default SSH_AUTH_SOCK is the homelab guarded user agent
  #... (see zsh.nix), which signs only the homelab session certificate and
  #... refuses to add keys. The github-pa key lives in its own agent instead,
  #... on a fixed socket that only the github-pa block below names. No homelab
  #... host matches it, so the homelab never sees this agent.
  githubAgent = "${home}/.ssh/agent-github.sock";
  githubBlock = identityFile: {
    IdentityFile = identityFile;
    IdentitiesOnly = true;
    IdentityAgent = githubAgent;
    AddKeysToAgent = "yes";
  };
in
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings = {
      "*" = {
        Compression = true;
        #... The guarded agent refuses adds, so do not try on macOS.
        AddKeysToAgent = if isDarwin then "no" else "yes";
      };
    }
    // lib.optionalAttrs isDarwin {
      #... Account uarun: FIDO2 resident keys on the YubiKeys. The files are
      #... handles, not secrets, and are not managed here. No agent: every
      #... connection asks for a touch on whichever YubiKey is plugged in.
      "github.com" = lib.hm.dag.entryBefore [ "*" ] {
        IdentitiesOnly = true;
        IdentityAgent = "none";
        IdentityFile = [
          "~/.ssh/id_github_yk-a_sk"
          "~/.ssh/id_github_yk-b_sk"
          "~/.ssh/id_github_yk-c_sk"
        ];
      };
      #... Account pa: use git@github-pa:<owner>/<repo>.git as the remote.
      "github-pa" = lib.hm.dag.entryBefore [ "*" ] (
        githubBlock "~/.ssh/id_github_pa" // { HostName = "github.com"; }
      );
    };
  };

  #... Apple's /usr/bin/ssh has no FIDO2 support. nixpkgs' openssh does, and
  #... the home profile comes before /usr/bin on PATH, so git uses it too.
  home.packages = lib.optionals isDarwin [ pkgs.openssh ];

  #... The ssh-agent for github-pa. It holds only keys that ssh adds on first
  #... use (AddKeysToAgent above), so each passphrase is typed once per login.
  launchd.agents.ssh-agent-github = lib.mkIf isDarwin {
    enable = true;
    config = {
      ProgramArguments = [
        "/bin/sh"
        "-c"
        ''rm -f "${githubAgent}"; exec ${pkgs.openssh}/bin/ssh-agent -D -a "${githubAgent}"''
      ];
      RunAtLoad = true;
      KeepAlive = true;
    };
  };
}
