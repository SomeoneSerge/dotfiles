# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./cuda-env.nix
  ];

  programs.cuda-env.enable = true;
  programs.atop = {
    enable = true;
    setuidWrapper.enable = true;
    atopgpu.enable = true;
  };

  nix = {
    package = pkgs.nixUnstable;
    extraOptions = ''
      experimental-features = nix-command flakes ca-derivations ca-references
    '';
    trustedUsers = [ "root" "ss" "kozluks1" ];
    gc.automatic = true;
    gc.options = "--delete-older-than 2d";
  };
  nixpkgs.config.allowUnfree = true;
  hardware.enableAllFirmware = true;
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };
  hardware.nvidia.modesetting.enable = true;
  services.xserver.displayManager.gdm.nvidiaWayland = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.configurationLimit = 16;
  boot.blacklistedKernelModules = [ "nouveau" ];

  virtualisation.docker.enable = true;
  virtualisation.docker.enableNvidia = true;
  systemd.enableUnifiedCgroupHierarchy = false; # otherwise nvidia-docker fails

  networking.domain = "aalto.fi";
  networking.hostName = "cs-338"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  networking.hosts = {
    "5.2.76.123" = [ "lite21" ];
    "fc7f:217a:060b:504b:8538:506a:e573:6615" = [ "lite21.k" ];
    "200:a734:be5d:b805:fcd5:4526:1937:4832" = [ "lite21.ygg" ];
    "201:898:d5f1:3941:bd2e:229:dcd4:dc9c" = [ "devbox.ygg" ];
    "fc76:d36c:8f3b:bbaa:1ad6:2039:7b99:7ca6" = [ "devbox.k" ];
    "200:cfad:3173:822e:39b:6965:e250:2053" = [ "ss-x230.ygg" ];
    "fc1e:8533:2b39:a16a:24d1:87a5:2c6b:7f35" = [ "ss-x230.k" ];
  };

  # Set your time zone.
  time.timeZone = "Europe/Helsinki";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp4s0.useDHCP = true;
  networking.networkmanager.enable = false;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];

  # Enable the Plasma 5 Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  services.xserver.displayManager.gdm.autoSuspend = false;

  services.haveged.enable = true;

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
  # users.users.jane = {
  #   isNormalUser = true;
  #   extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  # };
  users.users = {
    kozluks1 = {
      isNormalUser = true;
      extraGroups = [ "wheel" "video" ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMZCVSaUEokr9f55mKVWf4HzHsVIIY1CO089LuTJuHqS kozluks1@login3.triton.aalto.fi"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKonZ3Bjgl9t+MlyEIBKd1vIW3YYRV5hcFe4vKu21Nia newkozlukov@gmail.com"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOBpLSTazXGDwpor/rUv3jKzvgQw3xaAc9ujseMr3KzA ss@ss-x230"
      ];
      hashedPassword =
        "$6$akk0q5A5Df$tPay1nhDoPDGjy0Y68jd0cgmGq.gv6hPSV/28Bnzwqh4sD8pWCBgTI2H9VoFvtPbYffzBLnYOz8nGrUuHc5V4/";
    };
    ss = {
      isNormalUser = true;
      extraGroups = [ "wheel" "video" "docker" ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMZCVSaUEokr9f55mKVWf4HzHsVIIY1CO089LuTJuHqS kozluks1@login3.triton.aalto.fi"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKonZ3Bjgl9t+MlyEIBKd1vIW3YYRV5hcFe4vKu21Nia newkozlukov@gmail.com"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOBpLSTazXGDwpor/rUv3jKzvgQw3xaAc9ujseMr3KzA ss@ss-x230"
      ];
      hashedPassword =
        "$6$akk0q5A5Df$tPay1nhDoPDGjy0Y68jd0cgmGq.gv6hPSV/28Bnzwqh4sD8pWCBgTI2H9VoFvtPbYffzBLnYOz8nGrUuHc5V4/";
    };
  };

  programs.neovim.enable = true;
  programs.mosh.enable = true;
  programs.tmux.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    git
    nixfmt
    wget
    nmap
    firefox
    ag
    ripgrep
    fd
    pavucontrol
    pass-wayland
    htop
    iotop
    qrencode
    imv
    vlc
    wireguard
    logseq
    ffmpeg-full
    gimp
    vpn-slice
    p7zip
    blender
    (conda.override {
      condaDeps = [
        stdenv.cc
        xorg.libSM
        xorg.libICE
        xorg.libX11
        xorg.libXau
        xorg.libXi
        xorg.libXrender
        libselinux
        libGL
        glib
        # maybe add this? doesn't appear to be required
        # config.boot.kernelPackages.nvidia_x11
        # cudatoolkit_11_2
      ];
    })
    # nixGLNvidia
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    pinentryFlavor = "gnome3";
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = true;

  networking.wg-quick.interfaces.wg24601 = {
    address = [ "10.24.60.14" ];
    privateKeyFile = "/var/lib/wireguard/wg-${config.networking.hostName}";
    peers = [{
      publicKey = "60oGoY7YyYL/9FnBAljeJ/6wyaWZOvSQY+G1OnmKYmg=";
      endpoint = "5.2.76.123:51820";
      allowedIPs = [ "10.24.60.0/24" ];
      persistentKeepalive = 5;
    }];
  };
  systemd.services.ping-wireguard = {
    enable = true;
    script = ''
      ${pkgs.unixtools.ping}/bin/ping 10.24.60.1 -i 24
    '';
    after = [ "wg-quick-wg24601.service" ];
    serviceConfig = { LogLevelMax = 0; };
  };

  services.cjdns = {
    enable = true;
    UDPInterface = {
      bind = "0.0.0.0:22623";
      connectTo = {
        "5.2.76.123:43211" = {
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
      Peers = [ "tcp://5.2.76.123:43212" ];
      NodeInfo = { name = config.networking.hostName; };
      SessionFirewall = {
        enable = true;
        AllowFromDirect = true;
      };
    };
  };

  services.flatpak.enable = true;
  programs.singularity.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?

}

