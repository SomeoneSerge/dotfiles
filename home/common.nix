{ pkgs, ... }:

let mainLocale = "en_US.UTF-8";
in {
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

    nixfmt
    nix-index
    nix-tree

    asciinema
    youtubeDL
    mediainfo
    graphicsmagick
    htop
    iotop

    patchelf
    stack
    bazel
    meson
    leiningen
    nodejs
    ccls

    wget
    traceroute
    iputils
    ipcalc
    dnsutils
    file
    mediainfo
  ];

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.man = {
    enable = true;
    generateCaches = true;
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
    modules = [ "host" "nix-shell" "cwd" "git" ];
    # pathAliases = { "\\~/project/foo" = "prj-foo"; };
    settings = {
      cwd-max-depth = 2;
      git-mode = "simple";
      #   ignore-repos = [ "/home/me/project1" "/home/me/project2" ];
    };
  };

  programs.fzf = { enable = true; };

  programs.bash = {
    enable = true;
    bashrcExtra = ''
      . ${pkgs.bash-completion}/share/bash-completion/bash_completion
           PROMPT_COMMAND="history -a; history -r"
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
