{ pkgs, ... }:

rec {
  imports = [ ./common.nix ./weechat.nix ];

  home.packages = with pkgs; [
    cmus
    haskell-language-server

    nixGLIntel

    mat2
    libreoffice

    colmap
    meshlab

    sshfs
  ];
  programs.kitty.enable = true;
}
