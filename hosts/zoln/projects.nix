{ pkgs, ... }:
{
  services.postgresql = {
    enable = true;
    authentication = pkgs.lib.mkOverride 10 ''
      #type database  DBuser  auth-method
      local all       all     trust
      host  sameuser    all     127.0.0.1/32 scram-sha-256
      host  sameuser    all     ::1/128 scram-sha-256
    '';
  };
}
