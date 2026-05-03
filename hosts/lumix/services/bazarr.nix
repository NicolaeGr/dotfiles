{ ... }:
{
  services.bazarr = {
    enable = true;
    openFirewall = true;
    user = "deploy";
    group = "users";
  };
}
