{ config, pkgs, ... }:

{
  imports = [
    ./common.nix
  ];

  home.packages = with pkgs; [
    mpv
    vlc
    deadbeef

    beets
    cmus
  ];
}
