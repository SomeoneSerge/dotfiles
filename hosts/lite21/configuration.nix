# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

let
  ipv4 = "5.2.76.123";
  cjdnsPort = 43211;
  yggdrasilPort = 43212;
  weechat' = builtins.head
    (import ../../home/weechat.nix { inherit pkgs; }).home.packages;
in {
  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./matrix.nix
  ];

  nix = {
    package = pkgs.nixUnstable;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.supportedFilesystems = [ "btrfs" ];
  # boot.loader.grub.efiSupport = true;
  # boot.loader.grub.efiInstallAsRemovable = true;
  # boot.loader.efi.efiSysMountPoint = "/boot/efi";
  # Define on which hard drive you want to install Grub.
  boot.loader.grub.device = "/dev/vda"; # or "nodev" for efi only
  # boot.loader.grub.device = "nodev";

  boot.kernel.sysctl = {
  
    "net.ipv6.conf.all.forwarding" = 1;
    "net.core.default_qdisc" = "cake";
    "net.ipv4.tcp_congestion_control" = "bbr";
    "net.ipv4.tcp_fastopen" = 3;
    "net.ipv4.tcp_rmem" = "4096 1048576 16777216";
    "net.ipv4.tcp_wmem" = "4096 65536 16777216";
    "net.core.rmem_default" = 1048576;
    "net.core.wmem_default" = 65536;
    "net.core.rmem_max" = 16777216;
    "net.core.wmem_max" = 16777216;
    "net.core.optmem_max" = 65536;
  };

  networking.hostName = "lite21"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Set your time zone.
  time.timeZone = "Europe/Helsinki";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.ens3.ipv4.addresses = [{
    address = ipv4;
    prefixLength = 24;
  }];
  networking.defaultGateway = {
    address = "5.2.76.1";
    interface = "ens3";
  };
  networking.nameservers = [ "1.1.1.1" ];

  networking.nat.enable = true;
  networking.nat.internalInterfaces = ["ve-+"];
  networking.nat.externalInterface = "ens3";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  # };

  # Configure keymap in X11
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # sound.enable = true;
  # hardware.pulseaudio.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.ss = {
    isNormalUser = true;
    description = "Someone Serge";
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKonZ3Bjgl9t+MlyEIBKd1vIW3YYRV5hcFe4vKu21Nia newkozlukov@gmail.com"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOBpLSTazXGDwpor/rUv3jKzvgQw3xaAc9ujseMr3KzA ss@ss-x230"
    ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    htop
    dnsutils
    ag ripgrep
    weechat'
    wget
    aria2
    git
    qrencode
    yrd
    cjdns-tools
  ];

  programs.tmux = {
    enable = true;
    clock24 = true;
    escapeTime = 100;
    keyMode = "vi";
    newSession = true;
  };

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

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  services.cjdns = {
    enable = true;

    # Public user password
    authorizedPasswords =
      [ "luDcKSyS0SpvLx3nSkTFAwMjL6JSpG7ZwzbfEcALYB2ceFSBiBNJJ0AfCY9yjPSq" ];

    UDPInterface.bind = "0.0.0.0:${toString cjdnsPort}";

    #  hyperboria/peers/blob/master/eu/nl/amsterdam/sabsare.geek.k
    UDPInterface.connectTo."163.172.222.21:3111" = {
      # "contact" = "sabsare@disroot.org";
      # "gpg" = "7267 B3AF BBA3 020D DAA9  00DC A4D0 24EC FAEF 0B4D";
      # "login" = "default-login";
      "password" = "lwmnsu9t63rzfbjj74ttv525s2phq96";
      "hostname" = "h.sabsare.geek";
      "publicKey" = "c6x0vfhh88ncz4by4ss3kmf09c7lp5nv9jufs8r3mkcudxfvb9v0.k";
    };
    # hyperboria/peers/eu/nl/amsterdam/unloved.vultar.ams.k
    UDPInterface.connectTo."45.76.38.114:19621" = {
      # "contact" = "polymorphm@gmail.com";
      # "gpg" = "ECAEF6E618F96F671A827ACA4049976115E6F6C7";
      # "login" = "default-login";
      "password" = "773vp0snvpjfnn5wb6pc4x5xl6j229v";
      "hostname" = "unloved.vultar.ams";
      "publicKey" = "vxh6lcjqgpgswbwmwu6wxd9kntflhwbpxfsw83ks9yf34jcqb7b0.k";
    };
    # eu/de/Frankfurt/sssemil.k
    UDPInterface.connectTo."45.32.152.232:5078" = {
      hostname = "ssemil.k";
      password = "v277jzr7r3jgk0vk1389b2c3h0gy98t";
      publicKey = "08bz912l989nzqc21q9x5qr96ns465nd71f290hb9q40z94jjw60.k";

    };
    # eu/ru/moscow/h.bunjlabs.com.k
    UDPInterface.connectTo."94.142.141.189:50433" = {
      password = "c5q2j63x5nkmt2yg2vjmlnfuh1jnjjf";
      hostname = "h.bunjlabs.com";
      publicKey = "0gdj2xzn01lzjjcrykjvwp8flnxkp1b3jny0drl5b168lmpsmfj0.k";
    };

    # eu/ru/novosibirsk/meanmail.k
    UDPInterface.connectTo."91.234.81.181:7485" = {
      password = "zfhb88fzf2lmpb5g2bgju6ps33lfr1c";
      hostname = "meanmail";
      publicKey = "0x3bvhjx0knnq67ruwmz369tuflr8zknkzbx7wgn60s4nujugdk0.k";
    };
    UDPInterface.connectTo."142.93.148.79:32307" = {
      # peerName = "kusoneko.moe";
      hostname = "kusoneko.moe";
      password = "242yl4g4nmu0rygusyhxu9xd13lrhuj";
      publicKey = "nvl82112jgj26sgv6r7sbuqc7wh1n7w1stsj327lbcu8n2yycf20.k";
      login = "public-peer";
      # contact = "kusoneko@kusoneko.moe";
      # location = "digitalocean tor1";
      # gpg = "E5FD4F97502A0BB304F44BA1440515F24B65A136";
    };
  };

  services.yggdrasil = {
    enable = true;
    persistentKeys = true;
    config = {
      Listen = [ "tcp://0.0.0.0:${toString yggdrasilPort}" ];
      Peers = [
        "tls://65.21.57.122:35953"
        "tcp://130.61.65.117:80"
        "tls://45.147.198.155:6010"
        "tcp://51.15.118.10:62486"
      ];
      NodeInfo = { name = "lite21"; };
      SessionFirewall = {
        enable = true;
        AllowFromDirect = true;
        # WhitelistEncryptionPublicKeys = [
        #     "dfa6c4226ede9967fc0f3523d9a9b42d3be916c608cf4b364c92996ca5bbe620"
        # ];
      };
    };
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    passwordAuthentication = false;
  };
  programs.mosh.enable = true;

  security.acme.email = "smnXXs@protonmail.com";
  security.acme.acceptTerms = true;
  services.nginx = {
    enable = true;

    recommendedTlsSettings = true;
    recommendedOptimisation = true;
    recommendedGzipSettings = true;
    recommendedProxySettings = true;

    virtualHosts = {
      "someonex.net" = {
        forceSSL = true;
        enableACME = true;
        serverAliases = [ "www.someonex.net" ];
        locations."/" = { root = "/var/www/someonex.net"; };
      };
      "someones.tf" = {
        forceSSL = true;
        enableACME = true;
        serverAliases = [ "www.someones.tf" ];
        locations."/" = { root = "/var/www/someones.tf"; };
      };
    };
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  networking.firewall.allowedUDPPorts = [ cjdnsPort ];
  networking.firewall.allowedTCPPorts = [ yggdrasilPort 80 443 ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?

}

