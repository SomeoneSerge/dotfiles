{ config, pkgs, ... }:

{
  imports = [
    ./common.nix
    ./program/beets/default.nix
  ];

  home.packages = with pkgs; [
    mpv-with-scripts
    vlc
    deadbeef

    beets
    cmus
  ];

  services.gpg-agent = {
    pinentryFlavor = "gnome3";
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
