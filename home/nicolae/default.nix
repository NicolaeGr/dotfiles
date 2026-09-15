{ pkgs, ... }: {
  imports = [
    ./config
  ];

  packages = with pkgs; [
    arduino-ide
    fritzing
  ];
}
