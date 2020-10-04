{ config, pkgs, ... }:

{
  nixpkgs.overlays = [ (import ./overlays/pylinters.nix) ];

  imports = [
    ./program/terminal/tmux/default.nix
    ./program/editor/neovim/default.nix
    ./program/tools/audio/beets/default.nix
  ];

  # Let Home Manager install and manage itself.
  # programs.home-manager.enable = true;
  home.stateVersion = "20.09";

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  home.language.base = "en_US.UTF-8";
  home.packages = with pkgs; [
    cachix
    lorri
    direnv
    niv

    gist
    gitAndTools.hub
    gitAndTools.gh
    curl
    wget

    fish
    fd
    ag
    ripgrep
    fzf

    mosh

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
}
