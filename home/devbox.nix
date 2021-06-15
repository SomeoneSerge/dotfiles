{ config, pkgs, ... }:

let mainLocale = "en_US.UTF-8";
in {
  imports = [ ./common.nix ];

  home.sessionVariables = {
    FONTCONFIG_FILE = "${pkgs.fontconfig.out}/etc/fonts/fonts.conf";
    LOCALE_ARCHIVE = "${pkgs.glibcLocales}/lib/locale/locale-archive";
    LC_ALL = mainLocale;
    LANG = mainLocale;
    EDITOR = "nvim";
    PATH = "/bin:${config.home.homeDirectory}/.nix-profile/bin";
  };

  xdg.configFile."nixpkgs/config.nix".text = ''
    {
      allowUnfree = true;
    }
  '';

  services.gpg-agent = { pinentryFlavor = "tty"; };

  home.packages = with pkgs; [
    # nixUnstable
    nixModern # imported in ../overlays/default.nix from NixOS/nix flake
    pkgs.nixGLIntel
    # pkgs.nixGLNvidia
    yrd
    qrencode
    busybox
    less
    aria2
    # Not installing mosh, because of
    # https://github.com/NixOS/nixpkgs/issues/90523
    # mosh
    htop
  ];

  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    enableScDaemon = false;
  };

}
