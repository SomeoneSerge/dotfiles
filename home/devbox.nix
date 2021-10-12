{ config, pkgs, lib, ... }:

let
  inherit (lib) mkIf mkOption mkEnableOption types;
  cfg = config.some.devbox;
in
{
  options.some.devbox = {
    enable = mkEnableOption "Enable stuff specific to devbox0 (a non-NixOS system, proprietary sw, etc)";
  };
  config = mkIf cfg.enable {
    home.sessionVariables =
      let glibcLocales = pkgs.glibcLocales.override {
        locales = lib.unique ((lib.attrValues config.home.language) // [ "en_US.UTF-8" "en_GB.UTF-8" "ru_RU.UTF-8" ]);
      };
      in
      {
        FONTCONFIG_FILE = "${pkgs.fontconfig.out}/etc/fonts/fonts.conf";
        LOCALE_ARCHIVE = "${glibcLocales}/lib/locale/locale-archive";
        LC_ALL = config.home.language.base;
        LANG = config.home.language.base;
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
      nixUnstable
      # Not installing mosh, because of
      # https://github.com/NixOS/nixpkgs/issues/90523
      # mosh
    ];

    services.gpg-agent = {
      enable = true;
      enableSshSupport = true;
      enableScDaemon = false;
    };

  };
}
