# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ lib, config, pkgs, ... }:

with lib;
with builtins;

let
  some = config.some;
in
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./cuda-env.nix
  ];

  some.sane.enable = true;
  some.mesh.enable = true;

  networking.nameservers = [ "10.24.60.1" ];

  programs.cuda-env.enable = true;
  programs.atop = {
    enable = true;
    setuidWrapper.enable = true;
    atopgpu.enable = true;
  };

  nixpkgs.config.allowUnfree = true;
  hardware.enableAllFirmware = true;
  hardware.opengl.driSupport32Bit = true;
  hardware.nvidia.modesetting.enable = true;
  hardware.video.hidpi.enable = true;

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
  services.picom = {
    enable = true;
  };

  some.i3.enable = true;
  services.xserver.displayManager.lightdm.enable = true;

  services.xserver.exportConfiguration = true;
  services.xserver.xrandrHeads = [
    {
      # dell
      output = "DP-1";
      monitorConfig = ''
        DisplaySize 596.74 335.66
        Option "PreferredMode" "2048x1152_60.0"
      '';
    }
    {
      # benq
      output = "DP-2";
      primary = true;
      monitorConfig = ''
        DisplaySize 708.40 398.50
        Option "PreferredMode" "3840x2160_60.0"
      '';
    }
  ];

  home-manager.users.ss.programs.mpv = {
    enable = true;
    defaultProfiles = [ "gpu-hq" ];
    config = {
      profile = "gpu-hq";
      force-window = true;
      ytdl-format = "bestvideo+bestaudio";
      cache-default = 4000000;
    };
  };
  home-manager.users.ss.xdg = {
    mimeApps.defaultApplications = {
      "image/vnd.djvu" = "zathura.desktop";
    };
  };
  home-manager.users.ss.programs.zathura = {
    enable = true;
    extraConfig = ''
      set synctex true
    '';
    options = {
      synctex-editor-command = "nvr --remote-silent +%{input}:%{line}";
    };
  };
  home-manager.users.ss.programs.autorandr = {
    enable = true;
    hooks.postswitch = {
      "notify-i3" = "${some.i3.package}/bin/i3-msg restart";
      # FIXME: optionalAttrs
      "update-background" = "/run/current-system/systemd/bin/systemctl --user restart random-background";
    };
    profiles = {
      default = {
        fingerprint = {
          DP-1 = "00ffffffffffff0010ac67d0533151301e1c0103803c2278ee4455a9554d9d260f5054a54b00b300d100714fa9408180778001010101565e00a0a0a029503020350055502100001a000000ff00474838354438374e305131530a000000fc0044454c4c205532373135480a20000000fd0038561e711e000a20202020202001c6020322f14f1005040302071601141f1213202122230907078301000065030c001000023a801871382d40582c250055502100001e011d8018711c1620582c250055502100009e011d007251d01e206e28550055502100001e8c0ad08a20e02d10103e9600555021000018483f00ca808030401a50130055502100001e00000094";
          DP-2 = "00ffffffffffff0009d1258045540000051f0104b54628783e87d1a8554d9f250e5054a56b80818081c08100a9c0b300d1c0010101014dd000a0f0703e8030203500c48f2100001a000000ff0035324d30333833373031390a20000000fd00324c1e8c3c000a202020202020000000fc0042656e5120504433323030550a010002031ef15161605f5e5d101f222120051404131203012309070783010000a36600a0f0701f8030203500c48f2100001a565e00a0a0a029502f203500c48f2100001a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000050";
        };
        config =
          let
            benqRes = [ 3840 2160 ];
            dellRes = [ 2048 1152 ];
            dellPos = [ 0 0 ];
            add = lib.zipListsWith (fst: snd: fst + snd);
            rightOf = pos: res: [ (elemAt pos 0 + elemAt res 0) (elemAt pos 1) ];
            vecStr = lib.concatMapStringsSep "x" (x: toString x);
          in
          {
            DP-2 = {
              enable = true;
              primary = true;
              mode = vecStr benqRes;
              position = vecStr (rightOf dellPos dellRes);
            };
            DP-1 = {
              enable = true;
              mode = vecStr dellRes;
              position = vecStr dellPos;
            };
          };
      };
    };
  };

  services.printing.enable = true;

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
        "$6$QCzeutqVN3tQTT$1IUxUOhy.AuoT3qQO3fMXkGmVFoHRHn7rlso00.XO6RbY.ByBW8Xzzp92pUEzdWIQkckh3LG1yQU1v6jcwGip.";
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
  programs.thefuck.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    alacritty
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
          # maybe add this? doesn't appear to be required
          # config.boot.kernelPackages.nvidia_x11
          # cudatoolkit_11_2
        ];
      }
    )
    # nixGLNvidia
    xsel
    aria2
    nnn
    mc
    neovim-remote
    torbrowser
  ];

  services.jhub = {
    enable = true;
    host = "0.0.0.0";
    authentication = "jupyterhub.auth.DummyAuthenticator";
    extraConfig = ''
      c.DummyAuthenticator.password = "allyouneedisnix"
    '';
  };

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  networking.firewall.enable = true;
  networking.firewall.trustedInterfaces = [ "wg24601" ];

  networking.wg-quick.interfaces.wg24601 = {
    address = [ "10.24.60.14" ];
    privateKeyFile = "/var/lib/wireguard/wg-${config.networking.hostName}";
    peers = [
      {
        publicKey = "60oGoY7YyYL/9FnBAljeJ/6wyaWZOvSQY+G1OnmKYmg=";
        endpoint = "5.2.76.123:51820";
        allowedIPs = [ "10.24.60.0/24" ];
        persistentKeepalive = 5;
      }
    ];
  };
  systemd.services.ping-wireguard = {
    enable = true;
    script = ''
      ${pkgs.unixtools.ping}/bin/ping 10.24.60.1
    '';
    after = [ "wg-quick-wg24601.service" ];
    requiredBy = [ "wg-quick-wg24601.service" ];
    serviceConfig = { LogLevelMax = 0; };
  };

  xdg.portal.enable = true;
  services.flatpak.enable = true;
  programs.singularity.enable = true;
  home-manager.users.ss = { services.random-background.enableXinerama = true; };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?

}
