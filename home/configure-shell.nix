{ config, pkgs, lib, ... }:

let
  inherit (lib) mkIf mkOption mkEnableOption types;
  cfg = config.some;
in
{
  options = {
    some.configure-shell = mkOption {
      description = "Enable shell integrations (direnv, powerline, a ton of invasive stuff)";
      type = types.bool;
      default = true;
    };
  };
  config = mkIf cfg.configure-shell {
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
      nix-direnv.enableFlakes = true;
    };

    programs.man = {
      enable = true;
      generateCaches = true;
    };

    programs.htop = {
      enable = true;
      settings.highlight_base_name = true;
    };

    programs.zsh = {
      enable = true;
      enableAutosuggestions = true;
      enableCompletion = true;
      plugins = [ ];
      initExtra = ''
        bindkey -v
        bindkey "^[[1~" beginning-of-line
        bindkey "^[[H"  beginning-of-line
        bindkey "^[[F"  end-of-line
        bindkey "^[[4~"  end-of-line
        bindkey "^[[1;5D" backward-word
        bindkey "^[[1;5C" forward-word
        bindkey "^[[3~" delete-char
      '';
    };

    programs.starship.enable = true;
    programs.starship.settings = {
      add_newline = false;
      command_timeout = 50;
      aws.disabled = true;
    };

    programs.fzf = { enable = true; };

    programs.bash = {
      enable = true;
      bashrcExtra = ''
        . ${pkgs.bash-completion}/share/bash-completion/bash_completion
        PROMPT_COMMAND="history -a; history -r"
        PS1_SET_TITLE='\[\e]0;\u@\h:\w\a\]'
        PS1="$PS1_SET_TITLE""$PS1"
      '';
      shellOptions = [
        # Default
        "histappend"
        "checkwinsize"
        "extglob"
        "globstar"
        "checkjobs"
        # Custom
        "dirspell"
        "cdspell"
      ];
    };
  };
}
