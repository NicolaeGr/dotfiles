{ pkgs, ... }: {
  soularr = pkgs.callPackage ./soularr { };
  lidarr-nightly = pkgs.callPackage ./lidarr { };
}
