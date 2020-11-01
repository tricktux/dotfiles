//
//
// File:           user.js
// Description:    Firefox more usable settings
// Author:		    Reinaldo Molina
// Email:          rmolin88 at gmail dot com
// Revision:	    0.0.0
// Created:        Sat Jan 26 2019 01:46
// Last Modified:  Sat Jan 26 2019 01:46
// Obtained from:
/******************************************************************************
 * user.js                                                                    *
 * https://github.com/pyllyukko/user.js                                       *
 ******************************************************************************/

/******************************************************************************
 * My section                                                *
 ******************************************************************************/
// Mouse stuff
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
user_pref("extensions.pocket.enabled", false)

// Performance
// GPU hardware acceleration
user_pref("gfx.canvas.azure.accelerated", true)

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
