{ pkgs, ... }:

rec {
  imports = [
    ./common.nix
    ./weechat.nix
  ];

  home.packages = with pkgs; [
    nixfmt
    cmus
    haskell-language-server

    nixGLIntel
  ];
  services.gpg-agent = {
    pinentryFlavor = "gnome3";
  };
}
