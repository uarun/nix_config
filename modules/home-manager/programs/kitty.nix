{ pkgs, ... }:
{
  programs.kitty = {
    enable = true;
    package = pkgs.kitty;
    font = {
      package = pkgs.iosevka;
      name = "Iosevka";
    };
    themeFile = "gruvbox-dark";                #... Other options we like "Solarized Dark", "Gruvbox Dark", "Monokai Pro"
    settings = {
      bold_font = "auto";
      italic_font = "auto";
      bold_italic_font = "auto";
      font_size = if pkgs.stdenvNoCC.isDarwin then 18 else 12;
      strip_trailing_spaces = "smart";
      enable_audio_bell = "no";
      term = "xterm-256color";
      macos_titlebar_color = "background";
      macos_option_as_alt = "yes";
      scrollback_lines = 10000;
      shell_integration = "no-cursor";
      window_padding_width = 3;
      disable_ligatures = "cursor";         #... disable disable ligatures when the cursor is under them

      #... Tab bar
      tab_bar_edge  = "top";
      tab_bar_style = "powerline";
      tab_title_template = "{index}: {title}";
      active_tab_font_style = "normal";
      inactive_tab_font_style = "normal";
      tab_activity_symbol = "";
    };

    extraConfig = ''
      #... Key mappings
      map cmd+c        copy_to_clipboard
      map cmd+v        paste_from_clipboard

      ##... Window Management
      map cmd+o         launch --cwd=current --type=window
      map cmd+n         new_os_window
      map cmd+w         close_window
      map cmd+right     next_window
      map cmd+left      previous_window
      map cmd+up        move_window_forward
      map cmd+down      move_window_backward
      map cmd+l         next_layout

      ##... Tab Management
      map cmd+enter     launch --cwd=current --type=tab
      map cmd+alt+right next_tab
      map cmd+alt+left  previous_tab
    '';
  };
}
