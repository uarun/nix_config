_:
{
  programs.wezterm = {
    enable = true;
    extraConfig = ''
      local config = wezterm.config_builder()

      config.font = wezterm.font("Iosevka")
      config.font_size = 14
      config.color_scheme = "Catppuccin Mocha"
      config.enable_tab_bar = true
      config.hide_tab_bar_if_only_one_tab = true
      config.window_padding = { left = 3, right = 3, top = 3, bottom = 3 }
      config.audible_bell = "Disabled"
      config.scrollback_lines = 10000
      config.term = "wezterm"
      config.front_end = "OpenGL"
      config.enable_wayland = false
      config.max_fps = 30
      config.animation_fps = 1
      config.cursor_blink_rate = 0

      return config
    '';
  };
}
