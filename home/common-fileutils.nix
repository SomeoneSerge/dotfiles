{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    fd
    ag
    ripgrep
    fzf

    zip
    unzip
    gzip
    xz

    ncdu

    curl
    wget
  ];
}
