{ config, pkgs, ... }:

{
  nixpkgs.overlays = [ (import ./overlays/pylinters.nix) ];

  # Ignored anyway, because "restricted setting"
  # and "untrusted user":

  # xdg.configFile."nix/nix.conf".text = ''
  #   experimental-features = nix-command flakes
  #   '';

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
    nixUnstable

    gist
    gitAndTools.hub
    gitAndTools.gh
    curl
    wget

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
  programs.fish = {
    enable = true;
    shellInit = ''
        # TODO: Find a proper way to do it...
        set -p fish_function_path ${pkgs.fish-foreign-env}/share/fish-foreign-env/functions
        fenv source /etc/profile.d/nix.sh
        set -e fish_function_path[1]
        '';
  };
}
