{...}: {
  imports = [ ../../modules/home-manager/nix-daemon-config.nix ];

  programs.git.settings.user = {
    email = "Arun.Udayashankar@tpicap.com";
    name = "Arun Udayashankar";
  };
}
