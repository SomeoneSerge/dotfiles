{ config, pkgs, lib, ... }: {
  services.hostapd = {
    enable = true;
    interface = "wlp0s20u1";
    ssid = "Ziferblat";
    wpaPassphrase = "allyouneedislove";
    hwMode = "g";
    extraConfig = ''
      ieee80211n=1
      wme_enabled=1
      ht_capab=[HT40+][SHORT-GI-40][DSSS_CCK-40]
      rsn_pairwise=CCMP
      wpa_pairwise=TKIP
      wpa_key_mgmt=WPA-PSK
    '';
  };

  services.dnsmasq = lib.optionalAttrs config.services.hostapd.enable {
    enable = true;
    extraConfig = ''
      interface=${config.services.hostapd.interface}
      bind-dynamic
      bogus-priv
      dhcp-range=192.168.24.10,192.168.24.254,24h
    '';
  };

  networking.networkmanager.unmanaged = [ ]
    ++ lib.optional config.services.hostapd.enable
    "interface-name:${config.services.hostapd.interface}";

  networking.interfaces.${config.services.hostapd.interface}.ipv4.addresses =
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
