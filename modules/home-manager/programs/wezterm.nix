{ pkgs, ... }:
let
  wezterm-wrapped = pkgs.symlinkJoin {
    name = "wezterm-wrapped";
    paths = [ pkgs.wezterm ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      for bin in wezterm wezterm-gui wezterm-mux-server; do
        wrapProgram $out/bin/$bin \
          --prefix LD_LIBRARY_PATH : "${pkgs.lib.makeLibraryPath [ pkgs.libglvnd pkgs.mesa.drivers ]}"
      done
    '';
  };
in
{
  home.packages = [ wezterm-wrapped ];

  programs.wezterm = {
    enable = true;
    package = wezterm-wrapped;
    extraConfig = ''
      local config = wezterm.config_builder()

      config.font = wezterm.font("Iosevka Nerd Font Mono")
      config.font_size = 14
      config.color_scheme = "Catppuccin Mocha"
      config.enable_tab_bar = true
      config.hide_tab_bar_if_only_one_tab = true
      config.window_padding = { left = 3, right = 3, top = 3, bottom = 3 }
      config.audible_bell = "Disabled"
      config.scrollback_lines = 10000
      config.term = "wezterm"
      config.front_end = "Software"
      config.enable_wayland = false
      config.max_fps = 60
      config.animation_fps = 1
      config.cursor_blink_rate = 0

      config.keys = {
        {
          key = 'Enter',
          mods = 'SHIFT',
          action = wezterm.action.SendString '\x1b[13;2u',
        },
      }

      return config
    '';
  };
}
