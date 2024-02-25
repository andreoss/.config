{ config, pkgs, lib, inputs, ... }:
let
  cfg = config.home.web;

  mozilla-common-settings = {
    "security.cert_pinning.enforcement_level" = 0; # User MITM allowed
    "accessibility.force_disabled" = 1;
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
in {
  imports = [ ];
  options = {
    home.web = {
      enable = lib.mkEnableOption "Web programs.";
      default = true;
    };
  };
  config = {
    home = {
      sessionVariables.DEFAULT_BROWSER = "mozilla";
      file.".local/bin/mozilla" = {
        executable = true;
        text = ''
          #!/bin/sh
          exec firejail firefox "$@"
        '';
      };
      packages = with pkgs; [
        libressl
        wget
        curl
        telescope
        (pidgin.override { plugins = [ pidgin-otr ]; })
        dig.dnsutils
        jwhois
        mtr
        monero-gui
        tor-browser-bundle-bin
        ungoogled-chromium
        tdesktop
      ];
    };
    programs = {
      aria2 = {
        enable = cfg.enable;
        settings = {
          bt-save-metadata = true;
          seed-time = 0;
          seed-ratio = 0.0;
        };
      };
      browserpass = {
        enable = cfg.enable && config.programs.password-store.enable;
        browsers = lib.mkForce [ "brave" "chromium" "firefox" "librewolf" ];
      };
      chromium.enable = cfg.enable;
      chromium.package = pkgs.brave;
      firefox = lib.mkIf cfg.enable {
        enable = true;
        profiles."default" = {
          id = 0;
          extraConfig = builtins.readFile "${inputs.user-js}/user.js";
          settings = mozilla-common-settings;
          extensions = with pkgs.nur.repos.rycee.firefox-addons; [
            passff
            ublock-origin
            umatrix
            decentraleyes
            i-auto-fullscreen
            browserpass
            localcdn
            temporary-containers
            tridactyl
            istilldontcareaboutcookies
          ];
          containers = {
            "Work I" = {
              color = "blue";
              icon = "briefcase";
              id = 1;
            };
            "Work II" = {
              color = "red";
              icon = "briefcase";
              id = 2;
            };
            "Work III" = {
              color = "purple";
              icon = "briefcase";
              id = 3;
            };
            "Work IV" = {
              color = "yellow";
              icon = "briefcase";
              id = 5;
            };
            Edu = {
              color = "yellow";
              icon = "chill";
              id = 6;
            };
            Media = {
              color = "red";
              icon = "chill";
              id = 7;
            };
            Dangerous = {
              color = "red";
              icon = "fruit";
              id = 1000;
            };
          };
          search = {
            force = true;
            order = [ "DuckDuckGo" ];
            default = "DuckDuckGo";
            engines = {
              "Nix Packages" = {
                urls = [{
                  template = "https://search.nixos.org/packages";
                  params = [
                    {
                      name = "type";
                      value = "packages";
                    }
                    {
                      name = "query";
                      value = "{searchTerms}";
                    }
                  ];
                }];
                icon =
                  "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
                definedAliases = [ "@np" ];
              };

            };
          };
          bookmarks = [
            {
              name = "wikipedia";
              tags = [ "wiki" ];
              keyword = "wiki";
              url =
                "https://en.wikipedia.org/wiki/Special:Search?search=%s&go=Go";
            }
            {
              name = "kernel.org";
              url = "https://www.kernel.org";
            }
          ];
        };
        package = with pkgs;
          (firefox-esr.override {
            extraNativeMessagingHosts = [ passff-host ];
          });
        policies = {
          SearchBar = "separate";
          AppUpdateURL = "file:///dev/null";
          CaptivePortal = false;
          NoDefaultBookmarks = true;
          DisableBuiltinPDFViewer = true;
          PDFjs = { Enabled = false; };
          Permissions = { Locked = true; };
          PictureInPicture = {
            Enabled = false;
            Locked = true;
          };
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
          Extensions = {
            "Uninstall" = [
              "google@search.mozilla.org"
              "bing@search.mozilla.org"
              "amazondotcom@search.mozilla.org"
              "ebay@search.mozilla.org"
              "twitter@search.mozilla.org"
            ];
            "Install" = [
              "https://addons.mozilla.org/firefox/downloads/latest/browserpass-ce"
              "https://addons.mozilla.org/firefox/downloads/latest/containerise"
              "https://addons.mozilla.org/firefox/downloads/latest/decentraleyes"
              "https://addons.mozilla.org/firefox/downloads/latest/tridactyl-vim"
              "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin"
              "https://addons.mozilla.org/firefox/downloads/latest/umatrix"
              "https://addons.mozilla.org/firefox/downloads/latest/tab-reloader"
              "https://addons.mozilla.org/firefox/downloads/latest/windows-xp-internet-browser"
              "https://addons.mozilla.org/firefox/downloads/latest/greasemonkey"
            ];
          };
          ExtensionSettings = {
            "*" = { installation_mode = "force_installed"; };
          };
          NetworkPrediction = false;
          NewTabPage = false;
          OverrideFirstRunPage = "";
          OfferToSaveLogins = false;
          PasswordManagerEnabled = false;
          SanitizeOnShutdown = true;
          SearchEngines = {
            PreventInstalls = true;
            Default = "DuckDuckGo";
            Remove =
              [ "Google" "Bing" "Amazon.com" "Amazon.es" "eBay" "Twitter" ];
            Add = [ ];
          };
          FirefoxSuggest = {
            "WebSuggestions" = false;
            "SponsoredSuggestions" = false;
            "ImproveSuggest" = false;
            "Locked" = true;
          };
          Homepage = {
            Locked = true;
            URL = "https://lobste.rs";
            StartPage = "homepage-locked";
          };
        };
      };
    };
  };
}
