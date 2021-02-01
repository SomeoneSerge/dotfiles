{ config, pkgs, ... }:

{
  programs.tmux = {
    enable = true;
    clock24 = true;
    keyMode = "vi";
    baseIndex = 1;
    aggressiveResize = true;
    historyLimit = 100000;
    resizeAmount = 5;
    escapeTime = 0;

    plugins = with pkgs.tmuxPlugins; [
      # sensible
      gruvbox
      cpu
      pain-control
      fpp
      {
        plugin = resurrect;
        extraConfig = "set -g @resurrect-strategy-nvim 'session'";
      }
      {
        plugin = continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-save-interval '30'
        '';
      }
    ];
    extraConfig = ''
      # set -g @plugin 'seebi/tmux-colors-solarized'

      set -g focus-events on

      # More vi-like behaviour
      # Borrowed from https://github.com/srid/nix-config/blob/master/nix/tmux.nix
      bind Escape copy-mode
      bind-key -Tcopy-mode-vi 'Escape' send -X cancel
      '';
  };
}
