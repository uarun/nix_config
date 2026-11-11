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
  #... refuses to add keys. GitHub keys live in their own agent instead, on a
  #... fixed socket that only the GitHub blocks below name. No homelab host
  #... matches these blocks, so the homelab never sees this agent.
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
      #... Account uarun.
      "github.com" = lib.hm.dag.entryBefore [ "*" ] (githubBlock "~/.ssh/id_github_uarun");
      #... Account pa: use git@github-pa:<owner>/<repo>.git as the remote.
      "github-pa" = lib.hm.dag.entryBefore [ "*" ] (
        githubBlock "~/.ssh/id_github_pa" // { HostName = "github.com"; }
      );
    };
  };

  #... The GitHub-only ssh-agent. It holds only keys that ssh adds on first use
  #... (AddKeysToAgent above), so each passphrase is typed once per login.
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
