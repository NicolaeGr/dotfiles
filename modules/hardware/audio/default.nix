{ pkgs, username, ... }: {
  security.rtkit.enable = true;

  sound.enable = true;
  hardware.pulseaudio.enable = false;

  environment.systemPackages = with pkgs; [ pulseaudio ];

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  # Move to it's own file
  services.mpd = { enable = true; startWhenNeeded = true; };

  hardware.pulseaudio.extraConfig = "load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1";
  services.mpd.extraConfig = ''
    audio_output {
      type "pulse"
      name "Pulseaudio"
      server "127.0.0.1" # add this line - MPD must connect to the local sound server
    }
  '';
}
