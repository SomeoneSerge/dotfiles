{ config, pkgs, ... }:

{
  home.packages = with pkgs; [
    fd
    ag
    ripgrep
    fzf

    curl
    wget
  ];
}
