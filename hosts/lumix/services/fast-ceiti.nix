{ pkgs, ... }:
{
  systemd.services = {
    fast-ceiti = {
      description = "Fast CEITI Docker Compose App";
      after = [ "docker.service" ];
      requires = [ "docker.service" ];
      path = [
        pkgs.bash
        pkgs.docker
        pkgs.docker-compose
      ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        WorkingDirectory = "/shared/fast-ceiti";
        ExecStart = "${pkgs.bash}/bin/bash ./sail up -d";
        ExecStop = "${pkgs.bash}/bin/bash ./sail down";
        Restart = "on-failure";
        KillMode = "process";
        TimeoutStopSec = 10;
      };
      wantedBy = [ "multi-user.target" ];
    };
  }
  // builtins.listToAttrs (
    builtins.genList (i: {
      name = "fast-ceiti-queue@${toString (i + 1)}";
      value = {
        description = "Fast Ceiti Sail Queue Worker ${toString (i + 1)}";
        after = [
          "docker.service"
          "fast-ceiti.service"
        ];
        requires = [
          "docker.service"
          "fast-ceiti.service"
        ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          ExecStart = ''
            ${pkgs.docker}/bin/docker exec -w /var/www/html fast-ceiti-laravel.test-1 php artisan queue:work redis  --sleep=3 --tries=3 --timeout=90
          '';
          ExecStop = ''
            ${pkgs.docker}/bin/docker exec fast-ceiti-laravel.test-1 pkill -f "artisan queue:work"
          '';
          Restart = "always";
          KillMode = "process";
          TimeoutStopSec = 10;
        };
      };
    }) 3
  ); # Adjust this number for how many workers you want

  services.cron.systemCronJobs = [
    "* * * * * victor  ${pkgs.docker}/bin/docker exec -w /var/www/html fast-ceiti-laravel.test-1 php artisan schedule:run >> /dev/null 2>&1"
  ];
}
