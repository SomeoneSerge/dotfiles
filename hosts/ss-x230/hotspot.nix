{ config, pkgs, lib, ... }: {
  services.hostapd = {
    enable = true;
    interface = "wlp3s0";
    hwMode = "b";
    ssid = "Ziferblat";
    wpaPassphrase = "allyouneedislove";
  };

  services.dnsmasq = lib.optionalAttrs config.services.hostapd.enable {
    enable = true;
    extraConfig = ''
      interface=${config.services.hostapd.interface};
      bind-dynamic
      bogus-priv
      dhcp-range=192.168.24.10,192.168.24.254,24h
    '';
  };

  networking.networkmanager.unmanaged = [ ]
    ++ lib.optional config.services.hostapd.enable
    "interface-name:${config.services.hostapd.interface}";

  networking.interfaces.wlp3s0.ipv4.addresses =
    lib.optionals config.services.hostapd.enable [{
      address = "192.168.24.1";
      prefixLength = 24;
    }];

  networking.firewall.allowedUDPPorts =
    lib.optionals config.services.hostapd.enable [ 53 67 ];

  services.haveged.enable = config.services.hostapd.enable;

  networking.nat.internalInterfaces =
    lib.optional config.services.hostapd.enable
    config.services.hostapd.interface;
}
