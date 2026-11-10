{
  configVars,
  ...
}:
{
  networking.networkmanager.ensureProfiles.profiles.lan = {
    connection = {
      id = "lan";
      type = "ethernet";
      interface-name = "enp6s0";
      autoconnect = "true";
      autoconnect-priority = "100";
    };

    ipv4 = {
      method = "auto";
      dns = "${configVars.net.lan.serverIp};";
      ignore-auto-dns = "true";
      route1 = "${configVars.net.svc.subnet},${configVars.net.lan.serverIp}";
    };

    ipv6.method = "disabled";
  };
}
