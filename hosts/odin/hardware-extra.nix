{ inputs, ... }: {
  imports = [
    inputs.hardware.nixosModules.lenovo-ideapad-15arh05
  ];

  local.hw.audio.enable = true;
  local.hw.bluetooth.enable = true;

  local.hw.splitKb = true;
}
