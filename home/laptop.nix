{ pkgs, ... }:

rec {
  imports = [ ./common.nix ./weechat.nix ];

  home.packages = with pkgs; [
    nixfmt
    cmus
    haskell-language-server

    nixGLIntel
    graphicsmagick

    mat2
    libreoffice
  ];
  programs.kitty.enable = true;
}
