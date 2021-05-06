# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
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

  boot.kernel.sysctl = {
      "net.core.rmem_max" = 134217728;
      "net.core.wmem_max" = 134217728;
      "net.core.default_qdisc" = "fq";
      "net.ipv4.tcp_congestion_control" = "bbr";
  };

  networking.hostName = "ss-x230"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.hosts = {
      "fc7f:217a:060b:504b:8538:506a:e573:6615" = ["lite21.cjd"];
  };
  networking.networkmanager = {
      enable = true; # already enabled by gnome
      unmanaged = ["type:tun"];
  };

  # Set your time zone.
  time.timeZone = "Europe/Helsinki";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp0s25.useDHCP = true;
  networking.interfaces.wlp3s0.useDHCP = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  # };

  # Enable the X11 windowing system.
  services.xserver.enable = true;


  # Enable the GNOME 3 Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.displayManager.gdm.autoSuspend = false;
  services.xserver.desktopManager.gnome3.enable = true;
  programs.geary.enable = false;
  programs.evolution = {
      enable = true;
      plugins = with pkgs; [evolution-ews];
  };
  services.davmail = {
      # enable = true;
      url = "https://mail.aalto.fi/owa/";
      # url = "https://outlook.office365.com/owa/?realm=aalto.fi";
      # url = "https://outlook.office365.com/EWS/Exchange.asmx";
      config = {
      };
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

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.ss = {
    isNormalUser = true;
    description = "Someone Serge";
    extraGroups = [ "wheel" "networkmanager" ]; # Enable ‘sudo’ for the user.
    openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKonZ3Bjgl9t+MlyEIBKd1vIW3YYRV5hcFe4vKu21Nia newkozlukov@gmail.com"
    ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    ag ripgrep fd
    pass-wayland
    pavucontrol
    wl-clipboard
    logseq
    xournalpp
    htop
    iotop
    wget
    firefox
    mpv
    vlc
    obs-studio
    git
    qrencode
    imv
    yrd
  ];
  
  programs.neovim = {
    enable = true;

    defaultEditor = true;
    vimAlias = true;

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

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 5201 ];
  networking.firewall.allowedUDPPorts = [ 5201 ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;
  
  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      intel-compute-runtime
    ];
  };

  services.cjdns = {
      enable = true;
      UDPInterface = {
          bind = "0.0.0.0:22623";
          connectTo = {
              "5.2.76.123:43211" = {
                  password = "luDcKSyS0SpvLx3nSkTFAwMjL6JSpG7ZwzbfEcALYB2ceFSBiBNJJ0AfCY9yjPSq";
                  hostname = "lite21";
                  publicKey = "ld0wgbr2wr4ku7vfnhg16py5bpnpkjd0cmn046l51g4gsxvzllg0.k";
              };
          };
    };
  };
  
  services.flatpak.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?

}

