{ pkgs, ... }:
{
  programs.git = {
    enable = true;

    settings = {
      alias = {
        co      = "checkout";
        dc      = "diff --cached";
        dt      = "difftool";
        unstash = "stash pop";
      };

      github.user = "uarun";
      commit.verbose = true;
      pull.rebase = true;
    };
  };

  programs.delta = {
    enable = false;
    options = {
      syntax-theme = "Monokai Extended";
      side-by-side = true;
      line-numbers = true;
      navigate     = true;
    };
  };

  programs.difftastic = {
    enable = true;
    git.enable = true;
  };
}
