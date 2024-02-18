{
  self,
  inputs,
  config,
  pkgs,
  ...
}: {

  imports = [
    ./primaryUser.nix
    ./nixpkgs.nix
  ];

  programs.zsh.enable = true;

  user = {
    description = "Arun Udayashankar";
    home = "${if pkgs.stdenvNoCC.isDarwin then "/Users" else "/home"}/${config.user.name}";
    shell = pkgs.zsh;
  };

  #... Bootstrap home manager using system config
  hmgr = {
    imports = [
      ./home-manager
    ];
  };

  #... Let nix manage home-manager profiles and use global nixpkgs
  home-manager = {
    extraSpecialArgs = {inherit self inputs;};
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
  };

  #... Environment setup
  environment = {
    systemPackages = with pkgs; [
      # editors
      neovim

      # standard toolset
      coreutils-full
      findutils
      diffutils
      curl
      wget
      git
      jq

      # helpful shell stuff
      bat
      fzf
      ripgrep
    ];

    shells = with pkgs; [bash zsh fish];   #... List of acceptable shells in /etc/shells
  };

  #... Install documentation for systemPackages
  documentation.enable = true;

  #... Install Fonts
  fonts = {
    fontDir.enable = true;       #... If true, manually installed system fonts will be deleted !!
    fonts = with pkgs; [
      (nerdfonts.override {
        fonts = [
          "FiraCode"
          "Hasklig"
          "Inconsolata"
          "Iosevka"
          "IosevkaTerm"
          "JetBrainsMono"
          "Meslo"
          "Monofur"
          "NerdFontsSymbolsOnly"
          "SourceCodePro"
          "UbuntuMono"
          "VictorMono"
        ];
      })
      vistafonts                #... Adding this mainly for Consolas (this needs allowUnfree to be set to true)
    ];
  };
}
