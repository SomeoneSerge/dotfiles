# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

let
  ipv4 = "5.2.76.123";
  cjdnsPort = 43211;
  yggdrasilPort = 43212;
  wgInterface =
    builtins.head (builtins.attrNames config.networking.wireguard.interfaces);
  weechat' = builtins.head
    (import ../../home/weechat.nix { inherit pkgs; }).home.packages;
  hosts = {
    devbox = {
      wireguard = {
        publicKey = "zet7mw5HkFquB9nFWDXXDvIXjY/neglYeHMu7fFE0RE=";
        address = "10.24.60.21";
      };
    };
    aziz-thinkpad = {
      wireguard = {
        publicKey = "o/nWTwDjhZLIcJVSTYXVr8yoQI2l8dXQwqO+lRBOw24=";
        address = "10.24.60.31";
      };
    };
    ss-xps13.wireguard = {
      publicKey = "BN0ZmyKUe7Ayjovl35jkIei5wpkFy3SVhMrOOoe+6yE=";
      address = "10.24.60.11";
    };
    ss-wf.wireguard = {
      publicKey = "8hwA4Pz21JKy0aqOT02SfU7gqqBlk5N5t6b4igs8aXk=";
      address = "10.24.60.12";
    };
    ss-x230.wireguard = {
      publicKey = "MMumrXbsxq7t55oNUOT+nV4XPyPRkfiMKKGfM2IXNVg=";
      address = "10.24.60.13";
    };
    ferres.wireguard = {
      publicKey = "+AKen1JkXsII++GUCB9a16RcguGCOXwJVODIpLKQPBY=";
      address = "10.24.60.22";
    };
    cs-338.wireguard = {
      publicKey = "7UpQ3zxZ23lzsHsxz6hbPgElb0kQrCEw7+K7vOU3owI=";
      address = "10.24.60.14";
    };
  };
in
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./hardening.nix
    ./matrix.nix
    ./aziz-calibre.nix
  ];

  some.sane.enable = true;

  boot.kernelPackages = pkgs.linuxPackages; # _hardened fails to build
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
  boot.loader.grub.configurationLimit = 24;

  boot.kernelModules = [ "tcp_bbr" ];

  networking.hostName = "lite21";
  networking.domain = "someonex.net";

  networking.hosts = lib.mkMerge [
    {
      "${ipv4}" = [ "someonex.net" "ns1.someonex.net" "mail.someonex.net" "matrix.someonex.net" "www.someonex.net" "someones.tf" "lite21" ];
      "${hosts.devbox.wireguard.address}" = [ "devbox.ferres.ml" ];
      "${hosts.cs-338.wireguard.address}" = [ "jhub.cs-338.someonex.net" "cs-338.someonex.net" ];
      "fc7f:217a:060b:504b:8538:506a:e573:6615" = [ "lite21.k" ];
      "203:14db:1510:5009:f390:b491:a31c:68b3" = [ "lite21.ygg" ];
      "200:3877:9519:4b01:2cb1:42a5:2eda:b71c" = [ "devbox.ygg" ];
      "fc76:d36c:8f3b:bbaa:1ad6:2039:7b99:7ca6" = [ "devbox.k" ];
      "200:cfad:3173:822e:39b:6965:e250:2053" = [ "ss-x230.ygg" ];
      "fc1e:8533:2b39:a16a:24d1:87a5:2c6b:7f35" = [ "ss-x230.k" ];
      "fc16:d86c:486f:dc9e:b916:f727:7122:cfe7" = [ "cs-338.k" ];
      "200:b157:d9e8:bf43:344b:13eb:10dc:8658" = [ "cs-338.ygg" ];
    }
    (lib.mapAttrs'
      (hostName: cfg:
        lib.nameValuePair (cfg.wireguard.address)
          [ "${hostName}.wg.${config.networking.domain}" ])
      hosts)
  ];

  networking.wireguard.interfaces.wg24601 = {
    ips = [ "10.24.60.1/24" ];
    listenPort = 51820;

    # Waiting for systemd-networkd official support in NixOS...
    postSetup = ''
      ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.24.60.0/24 -o ens3 -j MASQUERADE
    '';
    postShutdown = ''
      ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.24.60.0/24 -o ens3 -j MASQUERADE
    '';

    privateKeyFile = "/etc/.secrets/wg-lite21.key";
    peers =

      lib.mapAttrsToList
        (hostName: cfg:
          with cfg.wireguard; {
            inherit publicKey;
            allowedIPs = [ "${address}/32" ];
          })
        hosts;
  };
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Set your time zone.
  time.timeZone = "Europe/Helsinki";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
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
  networking.nat.internalInterfaces = [ "ve-+" "wg24601" ];
  networking.nat.externalInterface = "ens3";

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
    iperf
    dnsutils
    silver-searcher
    ripgrep
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

  security.acme.defaults.email = "smnXXs@protonmail.com";
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
        locations."/~aziz" = {
          extraConfig = ''
            rewrite /~aziz(/.*) $1 break;
          '';
          proxyPass = "http://10.24.60.21:8000/$1";
        };
      };
      "someones.tf" = {
        forceSSL = true;
        enableACME = true;
        serverAliases = [ "www.someones.tf" ];
        locations."/" = { root = "/var/www/someones.tf"; };
      };
      "cs-338.someonex.net" = {
        locations."/.well-known".proxyPass = "http://cs-338.wg.someonex.net/.well-known";
      };
    };
  };

  networking.firewall.allowedUDPPorts = [ cjdnsPort 5201 51820 53 ];
  networking.firewall.allowedTCPPorts = [ yggdrasilPort 80 443 5201 22 ];

  networking.firewall.trustedInterfaces = [ wgInterface ];
  networking.firewall.logRefusedConnections = false;

  services.dnsmasq = {
    enable = true;
    servers = [ "1.1.1.1" "8.8.4.4" ];
    extraConfig = ''
      domain-needed
      bind-dynamic
      bogus-priv
      dhcp-authoritative
      dhcp-range=interface:${wgInterface},10.24.60.100,10.24.60.254,24h
      domain=${config.networking.domain}

      neg-ttl=1800
      cache-size=32768

      auth-server=someonex.net
      host-record=someonex.net,${ipv4}
      auth-zone=someonex.net,5.2.76.123/32,10.24.60.0/24

      srv-host=_matrix._tcp,matrix.someonex.net,10,100,443
      mx-host=someonex.net,mail.someonex.net
    '';
  };
  systemd.services.dnsmasq.after = [ "wireguard-${wgInterface}.service" ];

  services.fail2ban = {
    enable = true;
    ignoreIP = [ "10.24.60.0/24" ];

  };
  systemd.services.fail2ban.serviceConfig.LimitSTACK = 256 * 1024;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?
}
