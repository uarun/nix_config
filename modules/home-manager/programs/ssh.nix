{ ... }: {
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks."*" = {
      compression = true;
      extraOptions = {
        AddKeysToAgent = "yes";
      };
    };
  };
}
