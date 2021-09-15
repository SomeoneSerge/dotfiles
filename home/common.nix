{ config, pkgs, ... }:

let mainLocale = "en_US.UTF-8";
in
{
  imports = [
    ./common-fileutils.nix
    ./common-gitutils.nix
    ./program/tmux/default.nix
    ./program/neovim/default.nix
  ];

  # Let's NOT let Home Manager install and manage itself.
  # programs.home-manager.enable = true;
  home.stateVersion = "20.09";

  home.language.base = mainLocale;

  home.packages = with pkgs; [
    home-manager

    cachix
    # lorri
    niv

    nixpkgs-fmt
    nixpkgs-review
    nix-visualize
    nix-index
    nix-tree

    asciinema
    youtubeDL
    mediainfo
    graphicsmagick
    iotop

    patchelf
    stack
    bazel
    meson
    leiningen
    nodejs
    jq
    ccls

    wget
    traceroute
    iputils
    ipcalc
    dnsutils
    file
    mediainfo

    tree
  ];

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

  programs.powerline-go = {
    enable = true;
    newline = false;
    modules = [ "host" "nix-shell" "cwd" "git" "exit" ];
    # pathAliases = { "\\~/project/foo" = "prj-foo"; };
    settings = {
      cwd-max-depth = 2;
      git-mode = "simple";
      #   ignore-repos = [ "/home/me/project1" "/home/me/project2" ];
    };
    extraUpdatePS1 = ''
      PS1_SET_TITLE='\[\e]0;\u@\h:\w\a\]'
      PS1="$PS1_SET_TITLE""$PS1"
    '';
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
}
