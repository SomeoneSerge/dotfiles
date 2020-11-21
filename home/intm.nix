{ config, pkgs, nixGL, ... }:

{
  imports = [
    ./common.nix
    ./program/beets/default.nix
    ./weechat.nix
  ];

  home.packages = with pkgs; [
    mpv-with-scripts
    vlc
    deadbeef

    beets
    cmus

    nixGLIntel
  ];

  programs.kitty = {
    enable = true;
  };
  programs.qutebrowser = {
    enable = true;
  };

  services.gpg-agent = {
    pinentryFlavor = "gnome3";
  };
  services.redshift = {
    enable = true;
    # extraOptions = [ "-m wayland" ];
    # package = pkgs.redshift-wlr;
    latitude = "55.6765651";
    longitude = "37.7623706";
    temperature = {
      day = 6000;
      night = 2100;
    };
  };

  home.sessionVariables = {
    MOZ_USE_XINPUT2 = 1;
    QT_WAYLAND_FORCE_DPI = "physical";
  };
}
