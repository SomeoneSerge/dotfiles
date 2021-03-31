{ config, pkgs, nixGL, ... }:

rec {
  imports = [
    ./common.nix
    ./weechat.nix
  ];

  home.packages = with pkgs; [
    # mpv-with-scripts
    # vlc
    # deadbeef

    # beets
    cmus

    nixGLIntel
  ];

  # GL apps don't work

  # programs.kitty = {
  #   enable = true;
  # };
  # programs.qutebrowser = {
  #   enable = true;
  # };

  services.gpg-agent = {
    pinentryFlavor = "gnome3";
  };
  services.redshift = {
    enable = true;
    # extraOptions = [ "-m wayland" ];
    settings = {
      redshift = {
        adjustment-method = "wayland";
      };
    };
    package = pkgs.redshift-wlr;
    latitude = "55.6765651";
    longitude = "37.7623706";
    temperature = {
      day = 6000;
      night = 2100;
    };
  };

  home.sessionVariables = {
    MOZ_USE_XINPUT2 = 1;
    MOZ_ENABLE_WAYLAND = 1;
    QT_WAYLAND_FORCE_DPI = "physical";
    GDK_BACKEND = "wayland";
    SDL_VIDEODRIVER = "wayland";
    CLUTTER_BACKEND = "wayland";
  };
}
