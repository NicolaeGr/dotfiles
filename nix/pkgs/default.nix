{ pkgs, ... }: {
  zsh-term-title = pkgs.callPackage ./zsh-term-title { };

  soularr = pkgs.callPackage ./soularr { };
}
