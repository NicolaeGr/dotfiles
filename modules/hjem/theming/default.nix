# ht: Omarchy-compatible theming.
#
# Themes render into one store path. ht swaps a symlink to the selected
# theme directory and runs each enabled target's switch hook.
{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.local.theming;
  targets = cfg._targets;

  themeNames = builtins.attrNames cfg.themes;
  defaultTheme =
    if cfg.default != null then
      cfg.default
    else if themeNames == [ ] then
      ""
    else
      builtins.head themeNames;

  toToml =
    attrs:
    lib.concatStringsSep "\n" (
      lib.mapAttrsToList (key: value: "${key} = ${builtins.toJSON value}") attrs
    )
    + "\n";

  colorsFile =
    name: theme:
    pkgs.writeText "ht-colors-${lib.strings.sanitizeDerivationName name}.toml" (
      if theme.colorsFile != null then builtins.readFile theme.colorsFile else toToml theme.colors
    );

  themeData =
    theme:
    if theme.colorsFile != null then
      builtins.fromTOML (builtins.readFile theme.colorsFile)
    else
      theme.colors;

  variantFor =
    theme:
    let
      data = themeData theme;
    in
    data.mode or data.theme_type or "dark";

  # Picks the first present string color, skipping gradients that cannot be
  # used as an SVG fill.
  colorOr =
    data: keys: fallback:
    let
      found = lib.findFirst (
        key: data ? ${key} && builtins.isString data.${key} && !(lib.hasInfix "gradient" data.${key})
      ) null keys;
    in
    if found == null then fallback else data.${found};

  xmlEscape =
    value:
    builtins.replaceStrings [ "&" "<" ">" "\"" "'" ] [ "&amp;" "&lt;" "&gt;" "&quot;" "&apos;" ] value;

  # A small mock window tinted with the theme colors, used as the menu card
  # thumbnail. The 360x220 canvas is twice the 180x110 card media box.
  previewSvg =
    name: theme:
    let
      data = themeData theme;
      bg = colorOr data [ "background" "color0" ] "#1d2021";
      panel = colorOr data [ "color8" "color0" ] "#282828";
      fg = colorOr data [ "foreground" "color7" ] "#ebdbb2";
      muted = colorOr data [ "color8" "color7" ] "#928374";
      accent = colorOr data [ "accent" "color4" "color6" ] "#83a598";
      red = colorOr data [ "color1" "color9" ] "#fb4934";
      green = colorOr data [ "color2" "color10" ] "#b8bb26";
      yellow = colorOr data [ "color3" "color11" ] "#fabd2f";
    in
    ''
      <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 360 220" width="360" height="220">
        <rect width="360" height="220" rx="12" fill="${bg}"/>
        <path d="M0 30h360V12a12 12 0 0 0-12-12H12A12 12 0 0 0 0 12z" fill="${panel}"/>
        <circle cx="20" cy="15" r="5" fill="${red}"/>
        <circle cx="38" cy="15" r="5" fill="${yellow}"/>
        <circle cx="56" cy="15" r="5" fill="${green}"/>
        <text x="180" y="19" text-anchor="middle" font-family="sans-serif" font-size="10" fill="${muted}">${xmlEscape name}</text>
        <rect x="16" y="46" width="90" height="158" rx="8" fill="${panel}"/>
        <rect x="28" y="60" width="66" height="8" rx="4" fill="${accent}"/>
        <rect x="28" y="78" width="50" height="6" rx="3" fill="${muted}"/>
        <rect x="28" y="94" width="58" height="6" rx="3" fill="${muted}"/>
        <rect x="28" y="110" width="44" height="6" rx="3" fill="${muted}"/>
        <rect x="122" y="46" width="222" height="70" rx="8" fill="${panel}"/>
        <rect x="138" y="62" width="120" height="10" rx="5" fill="${fg}"/>
        <rect x="138" y="82" width="188" height="6" rx="3" fill="${muted}"/>
        <rect x="138" y="96" width="170" height="6" rx="3" fill="${muted}"/>
        <rect x="122" y="128" width="104" height="76" rx="8" fill="${accent}"/>
        <rect x="240" y="128" width="104" height="76" rx="8" fill="${panel}"/>
        <rect x="256" y="144" width="72" height="8" rx="4" fill="${fg}"/>
        <rect x="256" y="160" width="56" height="6" rx="3" fill="${muted}"/>
        <rect x="256" y="176" width="64" height="6" rx="3" fill="${muted}"/>
      </svg>
    '';

  renderCommands =
    themeName: theme:
    lib.concatStrings (
      lib.mapAttrsToList (
        _: target:
        lib.concatStrings (
          lib.mapAttrsToList (output: template: ''
            mkdir -p "$out/$(dirname ${lib.escapeShellArg output})"
            ${pkgs.bash}/bin/bash ${./render.sh} \
              --colors ${lib.escapeShellArg (toString (colorsFile themeName theme))} \
              --template ${template} \
              --output "$out/"${lib.escapeShellArg output} \
              --name ${lib.escapeShellArg themeName}
          '') target.templates
        )
      ) targets
    );

  themeDrv =
    themeName: theme:
    pkgs.runCommand "ht-theme-${lib.strings.sanitizeDerivationName themeName}"
      {
        nativeBuildInputs = with pkgs; [
          bash
          coreutils
          gawk
          gnugrep
        ];
      }
      ''
        mkdir -p "$out"
        cp ${lib.escapeShellArg (toString (colorsFile themeName theme))} "$out/colors.toml"
        printf '%s\n' ${lib.escapeShellArg (variantFor theme)} >"$out/variant"
        cp ${pkgs.writeText "ht-preview-${lib.strings.sanitizeDerivationName themeName}.svg" (previewSvg themeName theme)} "$out/preview.svg"
        ${renderCommands themeName theme}
      '';

  themeDrvs = lib.mapAttrs themeDrv cfg.themes;

  hookFor =
    targetName: target:
    if target.switcher != null then
      target.switcher
    else if target.switcherScript != "" then
      pkgs.writeShellScript "ht-${lib.strings.sanitizeDerivationName targetName}" target.switcherScript
    else
      null;

  hookInstall =
    targetName: target:
    let
      hook = hookFor targetName target;
    in
    if hook == null then
      ""
    else
      ''
        install -m755 ${hook} "$out/libexec/${lib.strings.sanitizeDerivationName targetName}.sh"
      '';

  htScript = pkgs.replaceVars ./ht.sh {
    default = defaultTheme;
  };

  ht =
    pkgs.runCommand "ht"
      {
        nativeBuildInputs = [ pkgs.coreutils ];
      }
      ''
        mkdir -p "$out/bin" "$out/themes" "$out/libexec"

        ${lib.concatStrings (
          lib.mapAttrsToList (name: drv: ''
            cp -r ${drv} "$out/themes/"${lib.escapeShellArg name}
          '') themeDrvs
        )}

        install -m755 ${htScript} "$out/bin/ht"
        ln -s ht "$out/bin/ht-set"
        ln -s ht "$out/bin/ht-reload"
        ln -s ht "$out/bin/ht-list"

        install -Dm644 ${./completions/_ht} "$out/share/zsh/site-functions/_ht"
        install -Dm644 ${./completions/ht.bash} "$out/share/bash-completion/completions/ht"

        ${lib.concatStrings (lib.mapAttrsToList hookInstall targets)}
      '';

  allPackages = [
    ht
  ]
  ++ lib.optional (cfg.iconTheme.package != null) cfg.iconTheme.package
  ++ lib.optional (cfg.cursorTheme.package != null) cfg.cursorTheme.package
  ++ lib.concatLists (lib.mapAttrsToList (_: target: target.packages) targets);
in
{
  imports = [
    ./options.nix
  ]
  ++ lib.mapAttrsToList (name: _: ./targets + "/${name}") (
    lib.filterAttrs (_: type: type == "directory") (builtins.readDir ./targets)
  );

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        packages = allPackages;
      }

      # Hyprland reloads its config when this file changes. The store path is
      # part of the file so a rebuilt ht also changes the file, and
      # config.reloaded in autostart.lua asks ht to reapply.
      (lib.mkIf (targets ? hyprland) {
        files.".config/hypr/hyprland.lua".text = lib.mkAfter ''
          -- ht: ${ht}
        '';
      })
    ]
  );
}
