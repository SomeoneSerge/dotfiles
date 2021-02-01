{ config, pkgs, nixGL, ... }:

{
  imports = [
    ./common-nixutils.nix
    ./common-fileutils.nix
    ./common-gitutils.nix
    ./program/tmux/default.nix
    ./program/neovim/default.nix
  ];

  # Let's NOT let Home Manager install and manage itself.
  # programs.home-manager.enable = true;
  home.stateVersion = "20.09";

  home.sessionVariables = {
    EDITOR = "nvim";
    FONTCONFIG_FILE = "${pkgs.fontconfig.out}/etc/fonts/fonts.conf";
    LOCALE_ARCHIVE = "${pkgs.glibcLocales}/lib/locale/locale-archive";
  };

  home.language.base = "en_US.UTF-8";
  home.packages = with pkgs; [
    nixUnstable
    # Not installing mosh, because of
    # https://github.com/NixOS/nixpkgs/issues/90523
    # mosh
    htop

    asciinema
    youtubeDL

    stack
    bazel
    meson
    leiningen
    nodejs
    ccls
  ];

  programs.man = {
    enable = true;
    generateCaches = true;
  };

  programs.bash = {
    enable = true;
    sessionVariables = config.home.sessionVariables;
    bashrcExtra = ''
      . ${pkgs.bash-completion}/share/bash-completion/bash_completion
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

  programs.fzf = {
    enable = true;
  };

  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    enableScDaemon = false;
  };
}
