{ pkgs, ... }:
{
  services.ollama = {
    enable = false;
    package = pkgs.unstable.ollama-cuda;
  };
}
