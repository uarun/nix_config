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

    plugins = with pkgs; [
      tmuxPlugins.sensible
      tmuxPlugins.extrakto
      tmuxPlugins.tmux-thumbs
      tmuxPlugins.tmux-fzf
      {
        plugin = tmuxPlugins.catppuccin;
        extraConfig = ''
          set -g @catppuccin_flavour 'mocha'
          set -g @catppuccin_window_tabs_enabled on
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

      ##... Reload config shortcut
      bind r source-file ~/.config/tmux/tmux.conf \; display "Tmux Config reloaded!"

      ##... Better splitting (mnemonic)
      unbind %
      bind | split-window -h -c "#{pane_current_path}"
      unbind '"'
      bind - split-window -v -c "#{pane_current_path}"
    '';
  };
}
