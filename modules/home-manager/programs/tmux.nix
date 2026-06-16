{ pkgs, ... }:
{
  programs.tmux = {
    enable = true;
    mouse = true;
    keyMode = "vi";
    baseIndex = 1;
    historyLimit = 50000;
    escapeTime = 10;
    terminal = "tmux-256color";
    shell = "${pkgs.zsh}/bin/zsh";

    ##... Let Neovim (autoread/autosave) and vim-tmux-navigator see terminal
    ##... focus changes; off by default in home-manager.
    focusEvents = true;

    plugins = with pkgs; [
      tmuxPlugins.sensible
      tmuxPlugins.extrakto
      {
        plugin = tmuxPlugins.tmux-thumbs;
        extraConfig = ''
          set -g @thumbs-command 'echo -n {} | xclip -selection clipboard'
        '';
      }
      tmuxPlugins.tmux-fzf
      {
        plugin = tmuxPlugins.catppuccin;
        extraConfig = ''
          set -g @catppuccin_flavor 'mocha'
          set -g @catppuccin_window_status_style "rounded"
          set -g @catppuccin_status_background "#242638"
          set -g @catppuccin_window_current_number_color "#{@thm_lavender}"  #... default is mauve

          #... At the zsh prompt show the last path component (basename) instead of user@host:/full/path;
          #... when a command like gtop/claude runs, show the live command (#{pane_current_command})
          #... rather than #W, so a manually-renamed or resurrect-restored window name can't get stuck.
          #... Claude Code sets its process title to its version (e.g. "2.1.177"), so for
          #... claude panes pane_current_command is a bare version string; treat any
          #... value starting with a digit ([0-9]*) like zsh and show the basename.
          #... Prefix a robot glyph when an AI agent runs in the active pane: Claude
          #... (version-like, [0-9]*) or kiro-cli (exact match).
          set -g @catppuccin_window_text " #{?#{||:#{m:[0-9]*,#{pane_current_command}},#{==:#{pane_current_command},kiro-cli}},🤖 ,}#{?#{||:#{==:#{pane_current_command},zsh},#{==:#{pane_current_command},kiro-cli},#{m:[0-9]*,#{pane_current_command}}},#{b:pane_current_path},#{pane_current_command}}"
          #... Append a magnifier glyph to the current window's segment whenever its
          #... active pane is zoomed (other panes hidden). Only the current window can
          #... be zoomed, so it only needs to live on @catppuccin_window_current_text.
          set -g @catppuccin_window_current_text " #{?#{||:#{m:[0-9]*,#{pane_current_command}},#{==:#{pane_current_command},kiro-cli}},🤖 ,}#{?#{||:#{==:#{pane_current_command},zsh},#{==:#{pane_current_command},kiro-cli},#{m:[0-9]*,#{pane_current_command}}},#{b:pane_current_path},#{pane_current_command}}#{?window_zoomed_flag, ,}"
        '';
      }
      {
        plugin = tmuxPlugins.resurrect;
        extraConfig = ''
          set -g @resurrect-strategy-vim 'session'
          set -g @resurrect-strategy-nvim 'session'
          set -g @resurrect-capture-pane-contents 'on'
        '';
      }
      {
        plugin = tmuxPlugins.continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-boot 'on'
          set -g @continuum-save-interval '10'
        '';
      }
    ];

    extraConfig = ''
      ##... Enable modified key encoding (Shift+Enter, etc.)
      set -g extended-keys on

      ##... Advertise 24-bit color for the outer terminal. default-terminal is
      ##... tmux-256color, so without this catppuccin's colors get quantized to
      ##... the 256-color palette instead of rendering as true RGB.
      set -as terminal-features ",*:RGB"

      ##... Close gaps in window numbers when a middle window is closed
      ##... (e.g. 1 2 3, close 2 -> renumbers to 1 2 instead of leaving 1 3).
      set -g renumber-windows on

      ##... Route copy-mode yanks to the system clipboard via OSC52 (works
      ##... locally and over SSH-capable terminals).
      set -g set-clipboard on

      ##... Vi-style yank in copy mode
      bind -T copy-mode-vi v send-keys -X begin-selection
      bind -T copy-mode-vi V send-keys -X select-line
      bind -T copy-mode-vi y send-keys -X copy-selection-and-cancel

      ##... Blinking cursor so active pane is obvious
      set -g cursor-style blinking-block

      ##... Reload config shortcut
      bind r source-file ~/.config/tmux/tmux.conf \; display "Tmux Config reloaded!"

      ##... Better splitting (mnemonic)
      unbind %
      bind | split-window -h -c "#{pane_current_path}"
      unbind '"'
      bind - split-window -v -c "#{pane_current_path}"

      ##... Make the status line pretty
      set -g status-right-length 100
      set -g status-left-length 100
      set -g status-left "#{E:@catppuccin_status_session}"
      set -g status-right "#{E:@catppuccin_status_application}"
      set -agF status-right "#{E:@catppuccin_status_weather}"
      set -agF status-right "#{E:@catppuccin_status_cpu}"
      set-window-option -g status-position top

      ##... Reserve a blank row directly beneath the (top) status bar so the
      ##... prompt never butts against it -- p10k drops its own leading empty
      ##... line whenever the prompt is at pane row 1 (after `clear`/Ctrl-L), so
      ##... we separate on the tmux side instead. With a 2-row status and
      ##... status-position top, format[0] is the top row and format[1] is the
      ##... row just above the pane content, so keep the real status in format[0]
      ##... and leave format[1] empty: bar on top, blank row, then the prompt.
      set -g 'status-format[1]' ""
      set -g status 2

      ##... The right-hand "application" pill (catppuccin) also renders
      ##... #{pane_current_command}, so it shows Claude Code's version-string
      ##... process title too. Show "claude" for those version-like commands and
      ##... keep the live command for everything else. Must run after the
      ##... catppuccin plugin (loaded before extraConfig), which sets the default.
      set -g @catppuccin_application_text " #{?#{m:[0-9]*,#{pane_current_command}},claude,#{pane_current_command}}"

      ##... automatic-rename names windows after #{pane_current_command}; for Claude
      ##... Code panes that is the bare version (e.g. "2.1.177"), which then gets
      ##... saved by resurrect. Rename those windows to "claude" instead.
      set -g automatic-rename-format "#{?pane_in_mode,[tmux],#{?#{m:[0-9]*,#{pane_current_command}},claude,#{pane_current_command}}}"

      ##... Use the outer terminal's background for the status bar instead of
      ##... catppuccin's @catppuccin_status_background. Must run after the
      ##... catppuccin plugin (which sets its own status-style), so it lives here
      ##... in extraConfig rather than in the plugin block.
      set -g status-style 'bg=terminal'

      ##... Report weather temperature in Fahrenheit (USCS) instead of metric
      set -g @tmux-weather-units 'u'

      ##... The cpu/weather plugins interpolate their #{cpu}/#{weather}
      ##... placeholders into status-right at load time, so they must run AFTER
      ##... status-right is set here (home-manager loads listed plugins before
      ##... extraConfig, so loading them via the plugins list leaves the
      ##... placeholders unsubstituted and the modules render empty).
      run-shell ${pkgs.tmuxPlugins.cpu.rtp}
      run-shell ${pkgs.tmuxPlugins.weather.rtp}
    '';
  };
}
