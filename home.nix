{ config, pkgs, ... }:

{
  imports = [
    ./program/terminal/tmux/default.nix
  ];
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  home.language.base = "en_US.UTF-8";
  home.packages = with pkgs; [
    lorri
    tmux
    direnv
    niv
    beets
    cmus
  ];

  programs.git = {
    enable = true;
    userName = "Serge K";
    userEmail = "newkozlukov@gmail.com";
    extraConfig = {
        pull.ff = "only";
        alias = {
            st = "status --short --untracked-files=no";
            fuckme = "reset --hard HEAD";
            fuckyou = "push --force";
            please = "push --force-with-lease";
        };
        color.ui = "auto";
    };
  };
  programs.man = {
    enable = true;
    generateCaches = true;
  };
  programs.beets = {
    enable = true;
    package = with pkgs; (
      beets.override
      {
        enableConvert = true;
        enableLoadext = true;
        enableKeyfinder = true;
        enableFetchart = true;
        enableThumbnails = true;
      }
    );
    settings = {
      directory=  "~/Music";
      library = "~/.config/beets/library.db";
      plugins = [
        "fromfilename"
        "fetchart"
        "lyrics"
        "lastgenre"
        "web" "bpd"
        "duplicates"
        "discogs"
        "ftintitle"
        "badfiles"
      ];
      import = {
          move = true;
      };
    };
  };

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "nk";
  home.homeDirectory = "/home/nk";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "20.09";
}
