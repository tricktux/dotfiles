{ inputs
, outputs
, lib
, config
, pkgs
, ...
}:
{
  programs.firefox = {
    enable = true;
    profiles.reinaldo = {
      bookmarks = { };
      extensions = with inputs.firefox-addons.packages.${pkgs.system}; [
        ublock-origin
        darkreader
        vimium
      ];
      bookmarks = { };
      settings = {
        "browser.disableResetPrompt" = true;
        "browser.download.panel.shown" = true;
        "browser.download.useDownloadDir" = false;
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
        "browser.shell.checkDefaultBrowser" = false;
        "browser.shell.defaultBrowserCheckCount" = 1;
        "browser.startup.homepage" = "https://web.tabliss.io/";
        "browser.uiCustomization.state" = ''{"placements":{"widget-overflow-fixed-list":[],"nav-bar":["back-button","forward-button","stop-reload-button","home-button","urlbar-container","downloads-button","library-button","ublock0_raymondhill_net-browser-action","_testpilot-containers-browser-action"],"toolbar-menubar":["menubar-items"],"TabsToolbar":["tabbrowser-tabs","new-tab-button","alltabs-button"],"PersonalToolbar":["import-button","personal-bookmarks"]},"seen":["save-to-pocket-button","developer-button","ublock0_raymondhill_net-browser-action","_testpilot-containers-browser-action"],"dirtyAreaCache":["nav-bar","PersonalToolbar","toolbar-menubar","TabsToolbar","widget-overflow-fixed-list"],"currentVersion":18,"newElementCount":4}'';
        "dom.security.https_only_mode" = true;
        "identity.fxaccounts.enabled" = false;
        "privacy.trackingprotection.enabled" = true;
        "signon.rememberSignons" = false;
        "browser.newtabpage.pinned" = [{
          title = "NixOS";
          url = "https://web.tabliss.io/";
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
        user_perf('browser.cache.disk.enable', false);
        user_perf('browser.cache.memory.enable', true);
        user_perf('browser.cache.memory.max_entry_size',-1);
        user_perf('browser.sessionstore.interval', 600000);

        // New tab:
        user_pref("browser.newtabpage.activity-stream.asrouter.userprefs.cfr";false);
        user_pref("browser.newtabpage.activity-stream.feeds.section.highlights";false);
        user_pref("browser.newtabpage.activity-stream.feeds.section.topstories";false);
        user_pref("browser.newtabpage.activity-stream.feeds.snippets";false);
        user_pref("browser.newtabpage.activity-stream.feeds.topsites";false);
        user_pref("browser.newtabpage.activity-stream.prerender";false);
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
