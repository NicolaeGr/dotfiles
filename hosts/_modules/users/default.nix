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
          "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCpcTEaX5ZIPRngZ1RzuFDlpCrsYH2NmHSpHENG8NgvDX+B6BEYn0C1/9gI7pq3ko8kCQa+VM9W5vwFjAZfrEQm6i58gYeg89coHqCKKBWRwPPb5LsI6YTTFNM+eqzZbujuUd8dKb38tx0vS6sMzN+5kBSy06e7SzhGdb/nuXICCMA/JthZSUHfP9ieug+kf3PGaUfSGTbOE4gKaG4xqFF39IJsAXzZmaCz7vdux7rkZFeomskv9MkvLLnArWcWCV2lXbjKbG1H5gV0+JUu968uW1zisxhLzT7ZTL3Rq2csN9il3VEYHAnF1wWePqAKxg0pGBASiDFTW5lFlS2NPewxL1Xu3pSzyTgPhEeMmvP44Pjtcc78xp92ZQHvuLB+aMuGPwLDdoxFy64it08Xv1DW45UtXByor7E6KxQ/7SNSeglN1s0dSPXFzyjb/xtI6iUqeF8jH3S5ZEf86KQt9pmF/dE5n0MUxhPq9JNWUWwEW0N9eFTeIKBDrin0oVOEvFk= victor@MD-10912-IT"
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
