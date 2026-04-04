{ pkgs, config, ... }:
{
  sops.secrets."hosts/zoln/pgadmin_pass" = { };

  services.pgadmin = {
    enable = true;
    port = 5050;

    initialEmail = "nicolaegr@proton.com";
    initialPasswordFile = config.sops.secrets."hosts/zoln/pgadmin_pass".path;
  };

  services.postgresql = {
    enable = true;
    authentication = pkgs.lib.mkOverride 10 ''
      # local connections: any user, any db, no password
      local   all     all     trust

      # allow nicolae to connect over IPv4/IPv6 with password
      host    all     nicolae   127.0.0.1/32   scram-sha-256
      host    all     nicolae   ::1/128        scram-sha-256

      # legacy user (if you still need it)
      host   sameuser all       127.0.0.1/32   scram-sha-256
      host   sameuser all       ::1/128        scram-sha-256
    '';
  };
}
