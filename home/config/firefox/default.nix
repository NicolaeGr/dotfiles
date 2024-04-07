{ inputs, pkgs, ... }: {
  search.engines = {
    "Nix Packages" = {
      urls = [{
        template = "https://search.nixos.org/packages";
        params = [
          { name = "type"; value = "packages"; }
          { name = "query"; value = "{searchTerms}"; }
        ];
      }];

      icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
      definedAliases = [ "@np" ];
    };
    "MyNixOS" = {
      urls = [{
        template = "https://mynixos.com/search";
        params = [
          { name = "q"; value = "{searchTerms}"; }
        ];
      }];

      icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
      definedAliases = [ "@mynixos" "@nix" ];
    };
  };
  search.force = true;

  settings = {
    "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
    "browser.urlbar.maxRichResults" = false;
    "browser.urlbar.clickSelectsAll" = false;
  };

  extensions = with inputs.firefox-addons.packages."x86_64-linux"; [
    bitwarden
    ublock-origin
    sponsorblock
    darkreader
    youtube-shorts-block
    sidebery
    startpage-private-search
  ];

  userChrome = builtins.readFile ./userChrome.css;
}
