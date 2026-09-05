{
  lib,
  pkgs,
  config,
  ...
}:

let
  inherit (lib.options) mkEnableOption mkPackageOption;
  inherit (lib.modules) mkIf;
  inherit (lib.generators) toKeyValue;

  cfg = config.rum-ext.programs.wget;
in
{
  options.rum-ext.programs.wget = {
    enable = mkEnableOption "wget";

    package = mkPackageOption pkgs "wget" {
      nullable = true;
    };

    settings = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      example = {
        "check-certificate" = "off";
        "hsts-file" = "$HOME/.cache/wget-hsts";
      };
      description = ''
        Wget configuration settings.
      '';
    };
  };

  config = mkIf cfg.enable {
    packages = mkIf (cfg.package != null) [ cfg.package ];

    xdg.config.files."wgetrc".text = toKeyValue { } cfg.settings;
  };
}
