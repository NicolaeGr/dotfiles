{ hostName, ... }: {
  networking = {
    networkmanager = {
      enable = true;
      wifi.powersave = true;
    };
    inherit hostName;
  };

  services.create_ap = {
    enable = true;
    settings = {
      INTERNET_IFACE = "wlp4s0";
      WIFI_IFACE = "wlan0";
      SSID = hostName;
      PASSPHRASE = "nutiodau";
    };
  };
}
