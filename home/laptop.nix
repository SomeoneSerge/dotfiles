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

    nnn
  ];

  programs.kitty.enable = true;

  programs.zathura.enable = true;
}
