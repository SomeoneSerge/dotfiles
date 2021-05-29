{ config, pkgs, ... }:

{
  imports = [
    ./common.nix
  ];

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

  services.gpg-agent = {
    pinentryFlavor = "tty";
  };

  home.packages = with pkgs; [
    nixModern /* imported in ../overlays/default.nix from NixOS/nix flake */
    pkgs.nixGLIntel
    # pkgs.nixGLNvidia
    yrd
    qrencode
    aria2
  ];
}
