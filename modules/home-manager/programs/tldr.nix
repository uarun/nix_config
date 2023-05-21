{...}: {
  programs.tealdeer = {
    enable = true;
    settings = {
      display = {
        compact = false;
        use_pager = false;   #... colors are messed up in the pager, else we would set this to true
      };
      updates = {auto_update = true;};
    };
  };
}
