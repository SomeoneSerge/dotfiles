# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  lite21ipv4 = "5.2.76.123";
  yggdrasilPort = 43212;
in {
  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  hardware.enableRedistributableFirmware = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "btrfs" ];

  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes ca-derivations ca-references
    '';
    gc.automatic = true;
    gc.options = "--delete-older-than 8d";
    buildCores = 3;
    maxJobs = 12;
  };

  boot.kernel.sysctl = {
    "net.ipv6.conf.all.forwarding" = 1;
    "net.core.default_qdisc" = "cake";
    "net.ipv4.tcp_congestion_control" = "bbr";
    "net.ipv4.tcp_rmem" = "4096 87380 16777216";
    "net.ipv4.tcp_wmem" = "4096 16384 16777216";
    "net.core.rmem_default" = 87380;
    "net.core.wmem_default" = 16384;
    "net.core.rmem_max" = 16777216;
    "net.core.wmem_max" = 16777216;
    "net.core.optmem_max" = 16384;
    "net.ipv4.route.flush" = 1;
    "net.ipv4.tcp_fastopen" = 3;
    "net.ipv4.tcp_window_scaling" = 1;
  };

  networking.hostName = "ss-xps13"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.hosts = {
    "${lite21ipv4}" = [ "lite21" ];
    "fc7f:217a:060b:504b:8538:506a:e573:6615" = [ "lite21.k" ];
    "201:898:d5f1:3941:bd2e:229:dcd4:dc9c" = [ "devbox.ygg" ];
    "fc76:d36c:8f3b:bbaa:1ad6:2039:7b99:7ca6" = [ "devbox.k" ];
    "200:cfad:3173:822e:39b:6965:e250:2053" = [ "ss-x230.ygg" ];
    "fc1e:8533:2b39:a16a:24d1:87a5:2c6b:7f35" = [ "ss-x230.k" ];
  };

  # Set your time zone.
  # time.timeZone = "Europe/Amsterdam";
  time.timeZone = "Europe/Helsinki";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.wlp58s0.useDHCP = true;
  networking.networkmanager = {
    enable = true;
    unmanaged = [ "type:tun" ];
  };
  networking.nameservers = [ "1.1.1.1" ];

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  # };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    logseq
    ag
    ripgrep
    fd
    pass-wayland
    pavucontrol
    wl-clipboard
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
    nixfmt
    lm_sensors
    tdesktop
    sshfs
    brightnessctl
    gnome.gnome-tweaks
    gnome.gnome-tweak-tool
    gnome.dconf-editor
    colmap
    dnsutils
    element-desktop
    ffmpeg-full
    syncplay
    gimp
  ];

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.displayManager.gdm.autoSuspend = false;
  services.xserver.desktopManager.gnome.enable = true;
  services.gnome.tracker.enable = true;

  programs.light.enable = true;
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true; # so that gtk works properly
    extraPackages = with pkgs; [
      swaylock
      swayidle
      wl-clipboard
      mako
      alacritty
      wofi
      dmenu
    ];
  };

  # Configure keymap in X11
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e";

  services.packagekit.enable = true;
  services.udev.packages = with pkgs; [ gnome3.gnome-settings-daemon ];
  services.fwupd.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  services.xserver.libinput.enable = true;
  services.xserver.libinput.touchpad.tapping = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  # users.users.jane = {
  #   isNormalUser = true;
  #   extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  # };
  users.users.ss = {
    isNormalUser = true;
    description = "Someone Serge";
    extraGroups =
      [ "wheel" "networkmanager" "video" ]; # Enable ‘sudo’ for the user.
    openssh.authorizedKeys.keys = [
      # "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKonZ3Bjgl9t+MlyEIBKd1vIW3YYRV5hcFe4vKu21Nia newkozlukov@gmail.com"
    ];
  };

  environment.sessionVariables.LC_ALL = "en_US.UTF-8";

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

  programs.mosh.enable = true;
  programs.tmux = {
    enable = true;
    clock24 = true;
    escapeTime = 100;
    keyMode = "vi";
    newSession = true;
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  };

  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      libva-full
      vaapiIntel # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
      vaapiVdpau
      libvdpau-va-gl
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
      intel-compute-runtime
    ];
  };

  xdg.portal.enable = true;
  services.flatpak.enable = true;
  programs.singularity.enable = true;

  services.yggdrasil = {
    enable = true;
    persistentKeys = true;
    config = {
      Peers = [ "tcp://${lite21ipv4}:${toString yggdrasilPort}" ];
      NodeInfo = { name = config.networking.hostName; };
      SessionFirewall = {
        enable = true;
        AllowFromDirect = true;
      };
    };
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

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?

}

