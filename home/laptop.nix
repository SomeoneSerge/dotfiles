{ pkgs, ... }:

rec {
  imports = [ ./common.nix ./weechat.nix ];

  home.packages = with pkgs; [
    sshfs
    nixfmt
    cmus
    haskell-language-server

    jq

    mat2
    libreoffice

    colmap
    meshlab

    sshfs
    nmap

    nnn

    gptfdisk

    wireguard
  ];

  programs.kitty.enable = true;

  programs.zathura.enable = true;
}
