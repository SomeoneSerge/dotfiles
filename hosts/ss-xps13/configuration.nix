# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

let
  lite21ipv4 = "5.2.76.123";
  yggdrasilPort = 43212;
in
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    # ../ss-x230/hotspot.nix
  ];

  networking.nat.enable = true;
  services.hostapd.interface = lib.mkForce "wlp58s0";
  networking.nat.externalInterface = "enp0s20f0u2";

  some.sane.enable = true;
  some.autosuspend = true;
  some.i3.enable = true;
  some.i3.batteryIndicator = true;
  some.mesh.enable = true;

  hardware.enableRedistributableFirmware = true;
  services.throttled = {
    enable = true;
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "btrfs" ];
  boot.kernelPackages = pkgs.linuxPackages_zen;
  boot.extraModprobeConfig = ''
    options usb-storage quirks=1d6b:0003:u
  '';
  boot.kernelParams = [
    "pci=nommconf"
  ];
  services.fwupd.enable = true;

  nix = { trustedUsers = [ "root" "ss" ]; };

  networking.hostName = "ss-xps13"; # Define your hostname.
  networking.domain = "someonex.net";
  networking.nameservers = [ "203:14db:1510:5009:f390:b491:a31c:68b3" "5.2.76.123" "1.1.1.1" ];
  networking.resolvconf = {
    enable = true;
    extraConfig = ''
      prepend_nameservers=203:14db:1510:5009:f390:b491:a31c:68b3
    '';
  };
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.hosts = {
    "${lite21ipv4}" = [ "lite21" ];
    "fc7f:217a:060b:504b:8538:506a:e573:6615" = [ "lite21.k" ];
    "203:14db:1510:5009:f390:b491:a31c:68b3" = [ "lite21.ygg" ];
    "201:898:d5f1:3941:bd2e:229:dcd4:dc9c" = [ "devbox.ygg" ];
    "fc76:d36c:8f3b:bbaa:1ad6:2039:7b99:7ca6" = [ "devbox.k" ];
    "200:cfad:3173:822e:39b:6965:e250:2053" = [ "ss-x230.ygg" ];
    "fc1e:8533:2b39:a16a:24d1:87a5:2c6b:7f35" = [ "ss-x230.k" ];
    "fc16:d86c:486f:dc9e:b916:f727:7122:cfe7" = [ "cs-338.k" ];
    "200:b157:d9e8:bf43:344b:13eb:10dc:8658" = [ "cs-338.ygg" ];
  };

  time.timeZone = "Europe/Helsinki";

  networking.interfaces.wlp58s0.useDHCP = true;
  networking.networkmanager = {
    enable = true;
    unmanaged = [ "type:tun" ];
  };

  environment.systemPackages = with pkgs; [
    logseq
    ag
    ripgrep
    fd
    file
    pass-wayland
    pavucontrol
    wl-clipboard
    xournalpp
    (
      mpv-with-scripts.override {
        scripts = [ pkgs.mpvScripts.mpris ];
      }
    )
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
    brightnessctl
    gnome.gnome-tweaks
    gnome.gnome-tweak-tool
    gnome.dconf-editor
    element-desktop
    ffmpeg-full
    syncplay
    gimp
    cinnamon.nemo
    gopass
    vpn-slice
    p7zip
    blender
    (
      conda.override {
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
        ];
      }
    )
    (python3.withPackages (ps: with ps; [ numpy scipy matplotlib opencv4 ]))
    firefox-wayland
    torsocks
    tor-browser-bundle-bin
    chromium
    aria2
    saccade
  ];

  programs.adb.enable = true;

  programs.chromium = {
    enable = true;
    defaultSearchProviderSearchURL = "https://duckduckgo.com/?q={searchTerms}";
    defaultSearchProviderSuggestURL =
      "https://duckduckgo.com/ac/?q={searchTerms}&type=list";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.displayManager.lightdm.enable = true;

  programs.light.enable = true;

  services.packagekit.enable = true;
  services.udev.packages = with pkgs; [ gnome3.gnome-settings-daemon ];

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;
  hardware.bluetooth = {
    enable = true;
    package = pkgs.bluezFull;
  };

  services.xserver.libinput.enable = true;
  services.xserver.libinput.touchpad.accelSpeed = "0.5";

  users.users.ss = {
    isNormalUser = true;
    description = "Someone Serge";
    extraGroups =
      [ "wheel" "networkmanager" "video" ]; # Enable ‘sudo’ for the user.
    openssh.authorizedKeys.keys = [
      # "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKonZ3Bjgl9t+MlyEIBKd1vIW3YYRV5hcFe4vKu21Nia newkozlukov@gmail.com"
    ];
  };

  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  };

  fonts.fontconfig.dpi = 192;
  services.xserver.xrandrHeads = [
    {
      output = "eDP-1";
      primary = true;
      monitorConfig = ''
        DisplaySize 293.76 165.24
      '';
    }
  ];
  hardware.video.hidpi.enable = true;
  hardware.opengl = {
    enable = true;
    driSupport = true;
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

  services.tor.enable = true;
  services.tor.client.enable = true;

  # services.beesd = {
  #   filesystems = {
  #     nixcrypt = {
  #       spec = "/dev/mapper/nixcrypt";
  #       hashTableSizeMB = 4096;
  #       extraOptions = [ "--thread-count" "1" ];
  #     };
  #   };
  # };

  services.btrfs.autoScrub = {
    enable = true;
    fileSystems = [ "/" ];
  };

  networking.wg-quick.interfaces.wg24601 = {
    address = [ "10.24.60.11" ];
    privateKeyFile = "/var/lib/wireguard/wg-${config.networking.hostName}";
    dns = [ "10.24.60.1" ];
    peers = [
      {
        publicKey = "60oGoY7YyYL/9FnBAljeJ/6wyaWZOvSQY+G1OnmKYmg=";
        endpoint = "5.2.76.123:51820";
        allowedIPs = [ "10.24.60.0/24" ];
        persistentKeepalive = 24;
      }
    ];
  };

  users.users.munge = {
    home = "/etc/munge";
    createHome = true;
  };
  services.slurm = {
    enableStools = true;
    clusterName = "cs-338";
    controlMachine = "10.24.60.14";
  };

  services.syncthing = {
    enable = true;
    # FIXME
    user = "ss";
    group = "users";
    dataDir = "/home/ss/.syncthing";
    configDir = "/home/ss/.config/syncthing";
  };

  home-manager.users.ss = {
    services.gammastep.enable = true;
    services.gammastep.dawnTime = "06:00";
    services.gammastep.duskTime = "22:00";
    some.enable-gui-busybox = true;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?
}
