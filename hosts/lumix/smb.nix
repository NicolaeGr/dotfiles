{
  config,
  pkgs,
  lib,
  ...
}:
{
  systemd.tmpfiles.rules = [

    "d /storage/smb 0777 root users - -"
  ];

  users.groups.sambashare = { };

  services.samba = {
    enable = true;
    settings.global = {
      security = "user";
      "map to guest" = "Bad User";
      "obey pam restrictions" = "Yes";
    };

    shares."storage" = {
      path = "/storage/smb";
      browseable = true;
      guestOk = false;
      readOnly = false;
      createMask = "0666";
      directoryMask = "0777";
    };
  };

  networking.firewall.allowedTCPPorts = lib.mkForce [ 445 ];
  networking.firewall.allowedUDPPorts = lib.mkForce [
    137
    138
  ];
}
