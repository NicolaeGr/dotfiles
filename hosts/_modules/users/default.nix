{
  self,
  inputs,
  config,
  ...
}:
{
  imports = [
    ./utils.nix
  ];

  config = {
    sops.secrets = {
      "passwords/nicolae".neededForUsers = true;
      "passwords/victor".neededForUsers = true;
      "passwords/adrian".neededForUsers = true;
      "passwords/deploy".neededForUsers = true;
    };

    hjem = {
      clobberByDefault = true;

      extraModules = [
        inputs.hjem-rum.hjemModules.default
        (self + "/home/_common")
      ];
    };

    local.users = {
      nicolae = {
        enable = true;
        hashedPasswordFile = config.sops.secrets."passwords/nicolae".path;
        extraGroups = [ "wheel" ];
        trustedKeys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGXCGZ+GCIYb5Kwv73T9GXn0zfF8VORf6HDjx39R+KgP nicolae@odin"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHfDaSjtslSu+N7+NRTVU2dycXsfgpfzzVmNBkgVWJWO nicolae@zoln"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA5NCnQC9er7RFTgS6HD1yVVMkq5eor9EiaDkrTsGZzb nicolae@sweet"
        ];
      };

      victor = {
        hashedPasswordFile = config.sops.secrets."passwords/victor".path;
        extraGroups = [ "wheel" ];
        trustedKeys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII70INxI2Hhwdn9oiPswqBP6YFPliQkJtrBj+Fdt35dP freelance"
          "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCVMV9JRp2V5530lAknrrChpv/+K2jUHdDAXni1ZLPPuAR70vCZO5dM0Q3fpR83PZtSHOgcn8JTc5LNWgvy29/mavyrqewpGXDxEgWWra0c336DoJnbHASH8gXnFc/MIXMQSmLz6wNsW/oR+vgXQtw+NKz5EmqBjCdZv0zzgPfFPcQLwRdasPmfzVREjomPz3TFmoFnec86xJy6XgY+AWD85QzglA6gxl9Irn8Jltl5uZiAXAmGwzxRplpTk0YL3sLUGrjAJ8LpSAEMVHYppur5CnDQRaNX2LByX9PwWgyw1ijGecwqURF/N4oUujvLkOFwYiIk0nvAYlQfG+3326nKP9WfcNiJoh3/qzmGB30wvPVTZCUJMfVCPuWUgxbJM4jw/V9RrNhtVWuH9FEPx1Q69/oobOI/IObVFVo7ZWXGEjGtAepHd+wDx6pNrbDDr323K12+Gg4BwQOt75V1MLi5gldbSx9tgrM6r9+ALEw/4UaRbyJgWTzss/zvAYvOGpjOjaMbCmmZMNrnue8CFmNQ1A9niX6OWUISTfGjWJhiUJYtrmgmB3JLeVSH9MHr1IOh++pXxyyxgQw0yNuRytUz+2AvfGUUgx9QSVMjM8TLZYNNb4CT5DCNFJo1gJ/of1JeV0EChZXJzUot22kOjrSMgY1CScxD2s9KVY+W8JFRXQ== victor@md-12215-it"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIInDvx3/yk2Dwo/+Wonf0E3RjcodO/aIDKk1nuEO/lEQ victor@ubuntu-8gb-nbg1-1"
        ];
      };

      adrian = {
        hashedPasswordFile = config.sops.secrets."passwords/adrian".path;
        extraGroups = [ "wheel" ];
        trustedKeys = [
          "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDQWR4QACwHbENj4nL8VaG7q2A/L5mhtTVbDTD1/AvrLzfq1Xfr7i2c0wnf6QKOHpp36dzTUZj+tEPRsc/ORavcWUxxZ5Bf24kpQ0LD4rJOCKLWMpCd26Y07XTEyTHaUksa8KsnW9eYteKsXZPunpGpP3RUpjF8aQWenWHA1pw6RHU63aDUwV6qIRLB/oM8okPl8qhwu7/j5WlpmhWYpM2OyhSzyOi01RsxQ8ce03IDABR5f0i/ph/XLciyKj/otP+WTqYlcFT6mgFCbmZD9hLG7wJRgpv9vtdVM3OAWj9I/RKT3in3w1sPlKQtdBA+5Usv10qfX/txXZnsehg9fVMoFzzOXKU2Qb+K+fGoGtRoPbjFDg7wjzfMtydbAzVmDgYJ8nhWRAx4MM+6/JF4pxZa7IX5EG5Fplx2t4I0tbEHU4INmawrzWldptQihveJhHNGBlkatj+R5JNwH543uB37wgE/sdLsK6NvKCsnVOhNZKKUsMugIePHNoQIJtDZHW8= adrian@light"
        ];
      };

      deploy = {
        hashedPasswordFile = config.sops.secrets."passwords/deploy".path;
        extraGroups = [ "wheel" ];
      };
    };
  };
}
