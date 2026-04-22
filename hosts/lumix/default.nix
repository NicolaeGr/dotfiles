{
  configLib,
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ./minecraft.nix
    ./cloudflare.nix
    ./media.nix
    ./fast-ceiti.nix
    ./smb.nix
    ./wireguard.nix
    ./router.nix
    ./projects.nix
    ./git.nix
    inputs.vscode-server.nixosModules.default
  ]
  ++ (map configLib.relativeToRoot [
    "hosts/_common/core"
    "hosts/_common/extra"
    "hosts/_common/users"
  ]);

  users.deploy.enable = true;
  users.victor.enable = true;
  users.adrian.enable = true;

  services.nginx.enable = true;
  security.acme = {
    acceptTerms = true;
    defaults.email = "nicolaegr@proton.me";
  };

  services.croc.enable = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  services.vscode-server = {
    enable = true;
    enableFHS = true;
  };

  services.fail2ban = {
    enable = true;

    jails = {
      nginx-http-auth = ''
        enabled  = true
        filter   = nginx-http-auth
        logpath  = /var/log/nginx/error.log
        maxretry = 3
        bantime  = 3600
      '';

      nginx-badbots = ''
        enabled = true
        filter  = nginx-badbots
        logpath = /var/log/nginx/access.log
        maxretry = 2
        bantime  = 86400
      '';
    };
  };
}
