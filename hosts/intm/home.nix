{ config, pkgs, ... }:

{
  imports = [
    ../../home-common.nix
  ];

  home.packages = with pkgs; [
    mpv
    vlc
    deadbeef
  ];
}
