{pkgs, ...}:
{
  programs.kitty = {
    enable = true;
    package = pkgs.kitty;
    font = {
      package = pkgs.iosevka;
      name = "Iosevka";
    };
    theme = "Solarized Light";
    settings = {
      bold_font = "auto";
      italic_font = "auto";
      bold_italic_font = "auto";
      font_size =
        if pkgs.stdenvNoCC.isDarwin
        then 18
        else 12;
      strip_trailing_spaces = "smart";
      enable_audio_bell = "no";
      term = "xterm-256color";
      macos_titlebar_color = "background";
      macos_option_as_alt = "yes";
      scrollback_lines = 10000;
      shell_integration = "no-cursor";
      window_padding_width = 3;
    };
  };
}
