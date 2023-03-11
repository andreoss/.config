{ lib, config, pkgs, inputs, ... }: {
  home.file.".local/bin/mozilla" = {
    executable = true;
    text = ''
      #!/bin/sh
      exec firefox "$@"
    '';
  };
  programs.browserpass = {
    enable = true;
    browsers = [ "brave" "chromium" "firefox" ];
  };
  programs.librewolf.enable = !config.mini;
  programs.chromium.enable = true;
  programs.chromium.package = pkgs.brave;
  programs.firefox = {
    enable = true;
    package = pkgs.wrapFirefox pkgs.firefox-unwrapped {
      extraPolicies = {
        NoDefaultBookmarks = true;
        DisableBuiltinPDFViewer = true;
        PDFjs = { Enabled = false; };
        Permissions = { Locked = true; };
        PictureInPicture = {
          Enabled = false;
          Locked = true;
        };
        CaptivePortal = false;
        DisableFeedbackCommands = true;
        DisableFirefoxAccounts = true;
        DisableFirefoxScreenshots = true;
        DisableFirefoxStudies = true;
        DisableForgetButton = true;
        DisableFormHistory = true;
        DisableMasterPasswordCreation = true;
        DisablePasswordReveal = true;
        DisablePocket = true;
        DisablePrivateBrowsing = true;
        DisableProfileImport = true;
        DisableProfileRefresh = true;
        DisableSafeMode = true;
        DisableSetDesktopBackground = true;
        DisableSystemAddonUpdate = true;
        DisableTelemetry = true;
        ManagedBookmarks = [ ];
        Bookmarks = [ ];
        "Extensions" = {
          "Install" = [
            "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin"
            "https://addons.mozilla.org/firefox/downloads/latest/tridactyl-vim"
            "https://addons.mozilla.org/firefox/downloads/latest/umatrix"
            "https://addons.mozilla.org/firefox/downloads/latest/browserpass-ce"
            "https://addons.mozilla.org/firefox/downloads/latest/decentraleyes"
          ];
        };
        ExtensionSettings = {
          "*" = { installation_mode = "force_installed"; };
        };
        NetworkPrediction = false;
        NewTabPage = false;
        OfferToSaveLogins = false;
        PasswordManagerEnabled = false;
        SanitizeOnShutdown = true;
        SearchEngines = {
          Default = "DuckDuckGo";
          Remove = [ "Google" "Bing" "Amazon.com" ];
          Add = [
            {
              "Name" = "Invidious";
              "Description" =
                "Search for videos, channels, and playlists on Invidious";
              "URLTemplate" =
                "https://invidious.snopyta.org/search?q={searchTerms}";
              "Method" = "GET";
              "IconURL" = "https://invidious.snopyta.org/favicon.ico";
              "Alias" = "invidious";
            }
            {
              "Name" = "GitHub";
              "Description" = "Search GitHub";
              "URLTemplate" = "https://github.com/search?q={searchTerms}";
              "Method" = "GET";
              "IconURL" = "https://github.com/favicon.ico";
              "Alias" = "github";
            }
            {
              "Name" = "Wikipedia (es)";
              "Description" = "Wikipedia (es)";
              "URLTemplate" =
                "https://es.wikipedia.org/w/api.php?action=opensearch&amp;format=xml&amp;search={searchTerms}&amp;namespace=100|104|0";
              "Method" = "GET";
              "IconURL" =
                "https://es.wikipedia.org/static/favicon/wikipedia.ico";
              "Alias" = "wikipedia-es";
            }
            {
              "Name" = "NixOS options";
              "Description" = "Search NixOS options by name or description.";
              "URLTemplate" =
                "https://search.nixos.org/options?query={searchTerms}";
              "Method" = "GET";
              "IconURL" = "https://nixos.org/favicon.png";
              "Alias" = "nixos-options";
            }
            {
              "Name" = "NixOS packages";
              "Description" = "Search NixOS options by name or description.";
              "URLTemplate" =
                "https://search.nixos.org/packages?query={searchTerms}";
              "Method" = "GET";
              "IconURL" = "https://nixos.org/favicon.png";
              "Alias" = "nixos-packages";
            }
          ];
        };
      };
    };
    profiles."default" = {
      id = 0;
      extraConfig = builtins.readFile "${inputs.user-js}/user.js";
      settings = {
        "accessibility.force_disabled" = 1;
        "browser.bookmarks.autoExportHTML" = false;
        "browser.places.importBookmarksHTML" = true;
        "browser.bookmarks.file" = builtins.toString ../bookmarks.html;
        "browser.bookmarks.restore_default_bookmarks" = true;
        "browser.cache.disk.enable" = false;
        "browser.cache.offline.enable" = false;
        "browser.link.open_newwindow" = 2;
        "browser.privatebrowsing.autostart" = true;
        "browser.search.searchEnginesURL" = "";
        "browser.startup.homepage" = "about:blank";
        "browser.tabs.tabMinWidth" = 16;
        "browser.uidensity" = 1;
        "extensions.abuseReport.enabled" = false;
        "full-screen-api.ignore-widgets" = true;
        "privacy.clearOnShutdown.offlineApps" = true;
        "privacy.clearOnShutdown.siteSettings" = true;
        "privacy.cpd.offlineApps" = true;
        "privacy.cpd.passwords" = true;
        "privacy.cpd.siteSettings" = true;
        "signon.rememberSignons" = false;
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        "font.default.x-western" = "Terminus";
        "font.name.monospace.x-western" = "Terminus";
        "font.name.sans-serif.x-western" = "Terminus";
        "font.name.serif.x-western" = "Terminus";
      };
    };
  };
}
