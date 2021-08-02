# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

let
  lite21ipv4 = "5.2.76.123";
  yggdrasilPort = 43212;
in {
  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./hotspot.nix
  ];

  nix = {
    package = pkgs.nixUnstable;
    extraOptions = ''
      experimental-features = nix-command flakes ca-derivations ca-references
    '';
  };
  nixpkgs.config.allowUnfree = true;
  hardware.enableAllFirmware = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "btrfs" ];
  boot.loader.grub.configurationLimit = 16;

  boot.kernel.sysctl = {
    "net.core.default_qdisc" = "cake";
    "net.ipv4.tcp_congestion_control" = "bbr";
    "net.ipv4.tcp_fastopen" = 0;
    "net.ipv4.tcp_rmem" = "4096 87380 16777216";
    "net.ipv4.tcp_wmem" = "4096 16384 16777216";
    "net.core.rmem_default" = 87380;
    "net.core.wmem_default" = 16384;
    "net.core.rmem_max" = 16777216;
    "net.core.wmem_max" = 16777216;
    "net.core.optmem_max" = 16384;
  };

  networking.hostName = "ss-x230"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.hosts = {
    # "151.101.86.217" = [ "cache.nixos.org" ];
    "fc7f:217a:060b:504b:8538:506a:e573:6615" = [ "lite21.cjd" ];
    "201:898:d5f1:3941:bd2e:229:dcd4:dc9c" = [ "devbox.ygg" ];
    "fc76:d36c:8f3b:bbaa:1ad6:2039:7b99:7ca6" = [ "devbox.k" ];
  };

  networking.networkmanager = {
    enable = true;
    # unmanaged = [ "type:tun" "interface-name:enp0s25" ];
    unmanaged = [ "type:tun" ];
  };
  networking.interfaces.enp0s25.useDHCP = true;

  networking.nameservers = [ "1.1.1.1" ];
  # networking.resolvconf.extraConfig = lib.strings.concatMapStringsSep "\n" (ip: "prepend_nameservers=${ip}") config.networking.nameservers;

  # Set your time zone.
  time.timeZone = "Europe/Helsinki";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 5201 ];
  networking.firewall.allowedUDPPorts = [ 5201 ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  networking.nat = {
    enable = true;
    externalInterface = "enp0s25";
    internalInterfaces = [ "wg24601" "tun0" "tun1" ];
  };

  networking.firewall.trustedInterfaces = [ "wg24601" ];

  networking.wg-quick.interfaces.wg24601 = {
    address = [ "10.24.60.13" ];
    privateKeyFile = "/var/lib/wireguard/wg-x230.key";
    peers = [{
      publicKey = "60oGoY7YyYL/9FnBAljeJ/6wyaWZOvSQY+G1OnmKYmg=";
      endpoint = "5.2.76.123:51820";
      allowedIPs = [ "10.24.60.0/24" ];
      persistentKeepalive = 24;
    }];
  };

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  # };

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.windowManager.i3.enable = true;
  xdg.portal.enable = true;
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true; # so that gtk works properly
    extraPackages = with pkgs; [
      swaylock
      swayidle
      wl-clipboard
      mako # notification daemon
      alacritty # Alacritty is the default terminal in the config
      dmenu # Dmenu is the default in the config but i recommend wofi since its wayland native
      waybar
      kanshi
    ];
  };
  environment.pathsToLink = [ "/libexec" ];
  environment.etc."sway/config".text = ''
    # Brightness
    bindsym XF86MonBrightnessDown exec "brightnessctl set 2%-"
    bindsym XF86MonBrightnessUp exec "brightnessctl set +2%"

    # Volume
    bindsym XF86AudioRaiseVolume exec 'pactl set-sink-volume @DEFAULT_SINK@ +1%'
    bindsym XF86AudioLowerVolume exec 'pactl set-sink-volume @DEFAULT_SINK@ -1%'
    bindsym XF86AudioMute exec 'pactl set-sink-mute @DEFAULT_SINK@ toggle'

    # Polkit
    exec /run/current-system/sw/libexec/polkit-gnome-authentication-agent-1
  '';
  programs.light.enable = true;

  # GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.displayManager.gdm.autoSuspend = false;
  services.xserver.desktopManager.gnome.enable = false;
  programs.geary.enable = false;
  programs.evolution = {
    enable = true;
    plugins = with pkgs; [ evolution-ews ];
  };
  services.davmail = {
    # enable = true;
    url = "https://mail.aalto.fi/owa/";
    # url = "https://outlook.office365.com/owa/?realm=aalto.fi";
    # url = "https://outlook.office365.com/EWS/Exchange.asmx";
    config = { };
  };

  # Configure keymap in X11
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput.enable = true;
  services.xserver.libinput.touchpad = { naturalScrolling = true; };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.ss = {
    isNormalUser = true;
    description = "Someone Serge";
    extraGroups = [ "wheel" "networkmanager" ]; # Enable ‘sudo’ for the user.
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKonZ3Bjgl9t+MlyEIBKd1vIW3YYRV5hcFe4vKu21Nia newkozlukov@gmail.com"
    ];
  };
  home-manager.users.ss = {
    wayland.windowManager.sway = {
      enable = true;
      wrapperFeatures.gtk = true;
      config = {
        terminal = "alacritty";
        modifier = "Mod4";
        startup = [{
          command =
            "~/.nix-profile/libexec/polkit-gnome-authentication-agent-1";
        }];
      };
    };
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    polkit_gnome
    ag
    ripgrep
    fd
    pass-wayland
    pavucontrol
    wl-clipboard
    logseq
    xournalpp
    htop
    iotop
    wget
    qutebrowser
    firefox-wayland
    mpv
    vlc
    obs-studio
    git
    qrencode
    imv
    yrd
    vim
  ];
  environment.variables.LC_ALL = "en_US.UTF-8";
  i18n.extraLocaleSettings = { LC_ALL = "en_US.UTF-8"; };

  programs.neovim = {
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

  programs.mosh.enable = true;
  programs.tmux = {
    enable = true;
    clock24 = true;
    escapeTime = 100;
    keyMode = "vi";
    newSession = true;
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    passwordAuthentication = false;
  };

  hardware.opengl = {
    enable = true;
    driSupport = true;
    extraPackages = with pkgs; [ intel-compute-runtime ];
  };

  services.cjdns = {
    enable = true;
    UDPInterface = {
      bind = "0.0.0.0:22623";
      connectTo = {
        "${lite21ipv4}:43211" = {
          password =
            "luDcKSyS0SpvLx3nSkTFAwMjL6JSpG7ZwzbfEcALYB2ceFSBiBNJJ0AfCY9yjPSq";
          hostname = "lite21";
          publicKey = "ld0wgbr2wr4ku7vfnhg16py5bpnpkjd0cmn046l51g4gsxvzllg0.k";
        };
      };
    };
  };

  services.yggdrasil = {
    enable = true;
    persistentKeys = true;
    config = {
      Peers = [ "tcp://${lite21ipv4}:${toString yggdrasilPort}" ];
      NodeInfo = { name = "ss-x230"; };
      SessionFirewall = {
        enable = true;
        AllowFromDirect = true;
      };
    };
  };

  services.haveged.enable = true;

  services.flatpak.enable = true;

  programs.singularity.enable = true;

  users.users.steam = {
    isNormalUser = true;
    description = "Some Steam User";
    hashedPassword =
      "$6$Pvct6qT3o/OSJO3/$8Kkx8/g/rO4Bqj9W.xrpyZdWmr9/99Z3n3As6RI9Jd.srZN4wzQSetIzqFbefccJGt0snBNOFeFn6ITLL2hQs.";
  };
  programs.steam.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?

}

