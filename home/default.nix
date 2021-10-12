{ config, pkgs, ... }:

{
  imports = [
    ./common.nix
    ./enable-nix-utils.nix
    ./configure-git.nix
    ./configure-shell.nix
    ./tmux.nix
    ./neovim/default.nix
    ./devbox.nix
  ];
}
