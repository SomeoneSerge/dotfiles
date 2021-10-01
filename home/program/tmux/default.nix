{ lib, config, pkgs, ... }:

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
        extraConfig =
          let
            resurrectPrograms' = [
              "vi"
              "~vim->vim"
              "~nvim->nvim"
              "less"
              "more"
              "man"
              "info"
              "~tail"
              "git log"
              "git diff"
              "git show"
              "~latexmk -pvc"
              "dmesg"
              "nnn"
              "top"
              "htop"
              "weechat"
              "ping"
              "~watch"
              "ssh"
              "mosh-client"
            ];
            sep = " ";
            hasWhiteSpaces = p: (builtins.match ".*[ \n\r\t].*" p) != null;
            escapeProg = p: if (hasWhiteSpaces p) then ''"${p}"'' else p;
            resurrectPrograms = lib.concatMapStringsSep sep escapeProg resurrectPrograms';
          in
          ''
            set -g @ressurect-processes '${resurrectPrograms}'
            set -g @resurrect-strategy-vim 'session'
          '';
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
