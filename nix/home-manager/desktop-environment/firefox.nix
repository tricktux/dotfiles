{ inputs
, outputs
, lib
, config
, pkgs
, ...
}:

# didn't fetchPypi because the nixOS patched version (2.8.0) is only on PyPI-testing
let
  pywalfox-native = pkgs.python3Packages.buildPythonPackage {
    pname = "pywalfox";
    version = "2.8.0rc1";

    src = pkgs.fetchFromGitHub {
      owner = "Frewacom";
      repo = "pywalfox-native";
      rev = "7ecbbb193e6a7dab424bf3128adfa7e2d0fa6ff9";
      hash = "sha256-i1DgdYmNVvG+mZiFiBmVHsQnFvfDFOFTGf0GEy81lpE=";
    };
  };
in
{
  home.packages = with pkgs; [
    pywalfox-native
  ];

  # Add chromium just in case something doesn't work
  programs.chromium = {
    enable = true;
    commandLineArgs =
      [
        "--enable-logging=stderr"
        "--ignore-gpu-blocklist"
      ];
    dictionaries =
      [
        pkgs.hunspellDictsChromium.en_US
      ];
  };
  programs.firefox = {
    enable = true;
    profiles.reinaldo = {
      search.engines =
        {
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

          "NixOS Wiki" = {
            urls = [{ template = "https://nixos.wiki/index.php?search={searchTerms}"; }];
            iconUpdateURL = "https://nixos.wiki/favicon.png";
            updateInterval = 24 * 60 * 60 * 1000; # every day
            definedAliases = [ "@nw" ];
          };

          "Bing".metaData.hidden = true;
          "Google".metaData.alias = "@g"; # builtin engines only support specifying one additional alias
        };
      bookmarks = [
        {
          name = "wikipedia";
          tags = [ "wiki" ];
          keyword = "wiki";
          url = "https://en.wikipedia.org/wiki/Special:Search?search=%s&go=Go";
        }
        {
          name = "kernel.org";
          url = "https://www.kernel.org";
        }
        {
          name = "Nix sites";
          toolbar = true;
        }
        {
          name = "homepage";
          url = "https://nixos.org/";
        }
        {
          name = "wiki";
          tags = [ "wiki" "nix" ];
          url = "https://nixos.wiki/";
        }
      ];
      # https://github.com/nix-community/nur-combined/blob/master/repos/rycee/pkgs/firefox-addons/generated-firefox-addons.nix
      extensions = with inputs.firefox-addons.packages.${pkgs.system}; [
        ublock-origin
        darkreader
        vimium
        firenvim
        pywalfox
      ];
      settings = {
        # https://firefox-source-docs.mozilla.org/browser/urlbar/preferences.html
        "browser.urlbar.showSearchSuggestionsFirst" = false;
        "browser.disableResetPrompt" = true;
        "browser.download.panel.shown" = true;
        "browser.download.useDownloadDir" = false;
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
        "browser.shell.checkDefaultBrowser" = false;
        "browser.shell.defaultBrowserCheckCount" = 1;
        "browser.startup.homepage" = "";
        "browser.uiCustomization.state" = ''{"placements":{"widget-overflow-fixed-list":[],"nav-bar":["back-button","forward-button","stop-reload-button","home-button","urlbar-container","downloads-button","library-button","ublock0_raymondhill_net-browser-action","_testpilot-containers-browser-action"],"toolbar-menubar":["menubar-items"],"TabsToolbar":["tabbrowser-tabs","new-tab-button","alltabs-button"],"PersonalToolbar":["import-button","personal-bookmarks"]},"seen":["save-to-pocket-button","developer-button","ublock0_raymondhill_net-browser-action","_testpilot-containers-browser-action"],"dirtyAreaCache":["nav-bar","PersonalToolbar","toolbar-menubar","TabsToolbar","widget-overflow-fixed-list"],"currentVersion":18,"newElementCount":4}'';
        "dom.security.https_only_mode" = true;
        "identity.fxaccounts.enabled" = false;
        "privacy.trackingprotection.enabled" = true;
        "signon.rememberSignons" = false;
        "browser.newtabpage.pinned" = [{
          title = "NixOS";
          url = "";
        }];
      };
      extraConfig = ''
        user_pref("general.smoothScroll.lines.durationMaxMS", 125);
        user_pref("general.smoothScroll.lines.durationMinMS", 125);
        user_pref("general.smoothScroll.mouseWheel.durationMaxMS", 200);
        user_pref("general.smoothScroll.mouseWheel.durationMinMS", 100);
        user_pref("general.smoothScroll.msdPhysics.enabled", true);
        user_pref("general.smoothScroll.other.durationMaxMS", 125);
        user_pref("general.smoothScroll.other.durationMinMS", 125);
        user_pref("general.smoothScroll.pages.durationMaxMS", 125);
        user_pref("general.smoothScroll.pages.durationMinMS", 125);
        user_pref("mousewheel.min_line_scroll_amount", 30);
        user_pref("mousewheel.system_scroll_override_on_root_content.enabled", true);
        user_pref("mousewheel.system_scroll_override_on_root_content.horizontal.factor", 175);
        user_pref("mousewheel.system_scroll_override_on_root_content.vertical.factor", 175);
        user_pref("toolkit.scrollbox.horizontalScrollDistance", 6);
        user_pref("toolkit.scrollbox.verticalScrollDistance", 2);

        // Disable pocket
        user_pref("extensions.pocket.enabled", false);

        // Performance
        // GPU hardware acceleration
        user_pref("gfx.canvas.azure.accelerated", true);

        // Cache to ram
        // user_perf('browser.cache.disk.enable', true);
        // 1000 is user UID, get it with id -u
        // user_perf('browser.cache.disk.parent_directory', "/run/user/1000/firefox");
        // Either or
        // user_perf('browser.cache.disk.enable', false);
        // user_perf('browser.cache.memory.enable', true);
        // user_perf('browser.cache.memory.max_entry_size',-1);
        // user_perf('browser.sessionstore.interval', 600000);

        // New tab:
        user_pref("browser.newtabpage.activity-stream.asrouter.userprefs.cfr",false);
        user_pref("browser.newtabpage.activity-stream.feeds.system.section.highlights", false);
        user_pref("browser.newtabpage.activity-stream.feeds.system.section.topstories", false);
        user_pref("browser.newtabpage.activity-stream.feeds.system.snippets", false);
        user_pref("browser.newtabpage.activity-stream.feeds.system.topsites", false);
        user_pref("browser.newtabpage.activity-stream.prerender", false);
      '';
    };
  };

  xdg.mimeApps.defaultApplications = {
    "text/html" = [ "firefox.desktop" ];
    "text/xml" = [ "firefox.desktop" ];
    "x-scheme-handler/http" = [ "firefox.desktop" ];
    "x-scheme-handler/https" = [ "firefox.desktop" ];
  };
}
