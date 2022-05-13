{ config, pkgs, lib, ... }:

let
  inherit (lib) mkIf mkOption mkEnableOption mkDefault types;
  cfg = config.some;
in
{
  options = {
    some.enable-busybox = mkOption {
      description = "Add throw-all-in packages";
      type = types.bool;
      default = true;
    };
    some.enable-gui-busybox = mkEnableOption "Enable throw-all-in GUI packages";
  };
  config = {
    # Let's NOT let Home Manager install and manage itself.
    # programs.home-manager.enable = true;
    home.stateVersion = "20.09";
    home.language.base = "en_GB.UTF-8";
    home.language.time = "en_CA.UTF-8";

    home.packages = with pkgs; (
      lib.optionals cfg.enable-busybox [
        # better tmux
        zellij

        gist
        gitAndTools.hub
        gitAndTools.gh

        asciinema
        yt-dlp
        mediainfo
        graphicsmagick
        iotop

        delta
        less
        qrencode

        stack
        bazel
        meson
        leiningen
        nodejs
        jq
        ccls

        cmus

        aria2
        wget
        sshfs
        traceroute
        iputils
        ipcalc
        dnsutils
        yrd
        nmap

        parallel

        file
        mediainfo
        mat2
        nnn
        gptfdisk

        fd
        silver-searcher
        ripgrep
        fzf

        zip
        unzip
        gzip
        xz

        ncdu

        curl
        wget

        watchexec
      ]
      ++ lib.optional (!config.programs.broot.enable) [ tree ]
      ++ lib.optionals cfg.enable-gui-busybox [
        libreoffice

        audacity

        colmap
        meshlab

        wireguard-tools
      ]
    );
    programs.zathura.enable = mkDefault cfg.enable-gui-busybox;
  };
}
