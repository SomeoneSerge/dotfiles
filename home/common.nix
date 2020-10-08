{ config, pkgs, ... }:

{
  nixpkgs.overlays = [ (import ../overlays/pylinters.nix) ];

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
  };

  home.language.base = "en_US.UTF-8";
  home.packages = with pkgs; [
    # Not installing mosh, because of
    # https://github.com/NixOS/nixpkgs/issues/90523
    # mosh

    asciinema
    youtubeDL
  ];

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

  services.gpg-agent = {
    enableSshSupport = true;
    pinentryFlavor = "gnome3";
  };

}
