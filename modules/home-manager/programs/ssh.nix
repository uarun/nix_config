_: {
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings."*" = {
      Compression = true;
      AddKeysToAgent = "yes";
    };
  };
}
