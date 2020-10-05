{ config, pkgs, ... }:

{
  imports = [
    ./common.nix
    ./program/beets/default.nix
  ];

  home.packages = with pkgs; [
    mpv
    vlc
    deadbeef

    beets
    cmus
  ];
}
