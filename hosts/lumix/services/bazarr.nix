{ ... }:
{
  services.bazarr = {
    enable = true;
    user = "deploy";
    group = "users";
  };
}
