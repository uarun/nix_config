_:
{
  programs = {
    git = {
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

    delta = {
      enable = false;
      options = {
        syntax-theme = "Monokai Extended";
        side-by-side = true;
        line-numbers = true;
        navigate     = true;
      };
    };

    difftastic = {
      enable = true;
      git.enable = true;
    };
  };
}
