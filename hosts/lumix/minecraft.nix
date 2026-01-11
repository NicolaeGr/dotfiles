{
  pkgs,
  inputs,
  config,
  ...
}:
let
  system = pkgs.stdenv.hostPlatform.system;
  mcManager = inputs.minecraft-manager.packages.${system}.minecraft-app-manager;
in
{

  services.cloudflare-dyndns.domains = [ "mc.electrolit.biz" ];

  environment.systemPackages = [
    pkgs.openjdk17
    mcManager
  ];

  systemd.services.minecraft-manager = {
    description = "Minecraft App Manager Service";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];

    serviceConfig = {
      ExecStart = "${mcManager}/bin/minecraft.manager --workingPath=/shared/minecraft";
      User = "minecraft";
      Group = "minecraft";
      Type = "simple";
      Restart = "always";
      RestartSec = 5;
      EnvironmentFile = config.sops.secrets."minecraft-env".path;
    };
  };

  users.users.minecraft = {
    isSystemUser = true;
    group = "minecraft";
    shell = "/bin/false";
    createHome = false;
  };
  users.groups.minecraft = { };

  networking.firewall.allowedTCPPorts = [
    25565
    25566
  ];
  networking.firewall.allowedUDPPorts = [
    25565
    25566
  ];
}
