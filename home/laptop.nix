{ pkgs, ... }:

rec {
  imports = [ ./common.nix ./weechat.nix ];

  home.packages = with pkgs; [
    nixFlakes
    cmus
    haskell-language-server

    jq

    nixGLIntel

    mat2
    libreoffice

    colmap
    meshlab

    sshfs
  ];
  programs.kitty.enable = true;
}
