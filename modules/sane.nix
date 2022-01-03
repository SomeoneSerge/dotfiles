{ config, pkgs, lib, ... }:

with lib;
with builtins;

let
  cfg = config.some.sane;
  xOn = config.services.xserver.enable;
  mkDefAttrs = mapAttrs (key: value: mkDefault value);
in
{
  options = { some.sane.enable = mkEnableOption "Enable sane defaults"; };
  config = mkIf cfg.enable {
    nix = {
      nixPath = mkDefault [ "nixpkgs=${pkgs.path}" ];
      package = mkDefault pkgs.nixUnstable;
      extraOptions = ''
        experimental-features = nix-command flakes ca-derivations
        keep-outputs = true
        keep-derivations = true
      '';
      gc.automatic = mkDefault true;
      gc.options = mkDefault "--delete-older-than 7d";
    };
    i18n.defaultLocale = mkDefault "en_US.UTF-8";
    i18n.extraLocaleSettings = {
      LC_ALL = mkDefault config.i18n.defaultLocale;
    };
    environment.variables.LC_ALL = mkDefault config.i18n.defaultLocale;

    # console = {
    #   font = "Lat2-Terminus16";
    #   keyMap = "us";
    # };

    programs.gnupg.agent = mkDefAttrs {
      enable = true;
      enableSSHSupport = true;
      pinentryFlavor = if xOn then "gnome3" else "curses";
    };
    services.openssh = {
      enable = mkDefault true;
      passwordAuthentication = mkForce false;
    };
    programs.mosh.enable = mkDefault true;
    networking.firewall.logRefusedConnections = mkDefault false;

    sound.enable = mkDefault xOn;
    hardware.pulseaudio.enable = mkDefault xOn;
    xdg.portal.enable = mkDefault xOn;
    services.xserver.libinput.enable = mkDefault xOn;
    services.xserver.libinput.touchpad.tapping = mkDefault true;
    services.xserver.libinput.touchpad.naturalScrolling = mkDefault true;
    hardware.opengl.driSupport = mkDefault true;
    services.xserver.layout = mkDefault "us,ru";
    services.xserver.xkbOptions = mkDefault "grp:shift_caps_switch";

    fonts.enableDefaultFonts = mkDefault true;
    fonts.enableGhostscriptFonts = mkDefault true;
    fonts.fontDir.enable = mkDefault true;
    fonts.fonts = with pkgs;
      if xOn then [
        source-code-pro
        anonymousPro
        hasklig
        roboto
        noto-fonts
        noto-fonts-extra
        noto-fonts-emoji
        font-awesome_5
        powerline-fonts
        powerline-symbols
      ] else
        [ ];
    fonts.fontconfig.defaultFonts = {
      monospace = [ "hasklig" "Source Code Pro" "Anonymous Pro" ];
      emoji = [ "FontAwesome5Free" "Noto Color Emoji" "Powerline Symbols" ];
      sansSerif = [ "Noto Sans" "DejaVu Sans" ];
      serif = [ "Noto Serif" "DejaVu Serif" ];
    };

    networking.firewall.enable = mkDefault true;

    boot.loader.grub.configurationLimit = mkDefault 16;
    boot.kernelModules = [ "tcp_bbr" ];

    # 999 is like mkDefault only overrides defaults from nixos
    boot.kernel.sysctl = mapAttrs (key: value: mkOverride 999 value) ({
      "net.ipv6.conf.all.forwarding" = 1;
      "net.ipv4.conf.all.forwarding" = 1;
      "net.core.default_qdisc" = "cake";
      "net.ipv4.tcp_congestion_control" = "bbr";
      "net.ipv4.tcp_rmem" = "4096 87380 4194304";
      "net.ipv4.tcp_wmem" = "4096 16384 4194304";
      "net.core.rmem_default" = 87380;
      "net.core.wmem_default" = 16384;
      "net.core.rmem_max" = 4194304;
      "net.core.wmem_max" = 4194304;
      "net.core.optmem_max" = 65536;
      "net.ipv4.route.flush" = 1;
      "net.ipv4.tcp_window_scaling" = 1;

      # Hardening options

      # Disable magic SysRq key
      "kernel.sysrq" = 0;
      # Ignore ICMP broadcasts to avoid participating in Smurf attacks
      "net.ipv4.icmp_echo_ignore_broadcasts" = 1;
      # Ignore bad ICMP errors
      "net.ipv4.icmp_ignore_bogus_error_responses" = 1;
      # Reverse-path filter for spoof protection
      "net.ipv4.conf.default.rp_filter" = 1;
      "net.ipv4.conf.all.rp_filter" = 1;
      # SYN flood protection
      "net.ipv4.tcp_syncookies" = 1;
      # Do not accept ICMP redirects (prevent MITM attacks)
      "net.ipv4.conf.all.accept_redirects" = 0;
      "net.ipv4.conf.default.accept_redirects" = 0;
      "net.ipv4.conf.all.secure_redirects" = 0;
      "net.ipv4.conf.default.secure_redirects" = 0;
      "net.ipv6.conf.all.accept_redirects" = 0;
      "net.ipv6.conf.default.accept_redirects" = 0;
      # Do not send ICMP redirects (we are not a router)
      "net.ipv4.conf.all.send_redirects" = 0;
      # Do not accept IP source route packets (we are not a router)
      "net.ipv4.conf.all.accept_source_route" = 0;
      "net.ipv6.conf.all.accept_source_route" = 0;
      # Protect against tcp time-wait assassination hazards
      "net.ipv4.tcp_rfc1337" = 1;
      # TCP Fast Open (TFO)
      "net.ipv4.tcp_fastopen" = 3;
    } // (optionalAttrs config.networking.nat.enable {
      "net.ipv6.conf.all.forwarding" = 1;
      "net.ipv4.conf.all.forwarding" = 1;
    }));
    networking.useDHCP = false;
    networking.networkmanager.unmanaged = mkDefault [ "type:tun" ];
    networking.nameservers = mkDefault [ "1.1.1.1" ];

    programs.tmux = {
      enable = true;
      clock24 = true;
      escapeTime = 100;
      keyMode = "vi";
      newSession = true;
    };
    programs.neovim = mkDefAttrs {
      enable = true;

      defaultEditor = true;

      configure = {
        customRC = ''
          :set smartindent
          :set expandtab
          :set tabstop=4
          :set shiftwidth=4
          :set numberwidth=4
          :set number
        '';
      };
    };
  };
}
