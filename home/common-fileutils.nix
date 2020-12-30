{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    fd
    ag
    ripgrep
    fzf

    ncdu

    curl
    wget
  ];
}
