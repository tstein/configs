// UI tweaks
user_pref("browser.aboutConfig.showWarning", false);
user_pref("browser.compactmode.show", true);
user_pref("browser.download.alwaysOpenPanel", false);
user_pref("browser.download.autohideButton", false);
user_pref("media.mediacontrol.stopcontrol.timer.ms", 60000);
// disable ^Q
user_pref("browser.quitShortcut.disabled", true);
user_pref("browser.showQuitWarning", true);
// enable the Add button in search engine settings
user_pref("browser.urlbar.update2.engineAliasRefresh", true);

// networking
user_pref("browser.fixup.dns_first_for_single_words", true);

// automated content feeds
user_pref("browser.newtabpage.activity-stream.feeds.section.topstories", false);
user_pref("browser.newtabpage.activity-stream.feeds.topsites", false);
user_pref("browser.newtabpage.activity-stream.showSearch", false);
user_pref("browser.newtabpage.activity-stream.showSponsored", false);
user_pref("browser.newtabpage.activity-stream.showSponsoredTopSites", false);
user_pref("browser.newtabpage.enabled", false);
user_pref("browser.newtabpage.enhanced", false);
user_pref("browser.newtabpage.introShown", true);
user_pref("browser.search.suggest.enabled", false);
user_pref("browser.urlbar.showSearchSuggestionsFirst", false);
user_pref("browser.urlbar.suggest.quicksuggest.nonsponsored", false);
user_pref("browser.urlbar.suggest.quicksuggest.sponsored", false);

// features
user_pref("extensions.pocket.enabled", false);
user_pref("browser.ml.enable", false);
user_pref("browser.ml.linkPreview.longPress", false);

// privacy & fingerprinting
user_pref("dom.battery.enabled", false);
// https://support.mozilla.org/en-US/kb/privacy-preserving-attribution
user_pref("dom.private-attribution.submission.enabled", false);

// telemetry
user_pref("app.shield.optoutstudies.enabled", false);
user_pref("datareporting.healthreport.uploadEnabled", false);
user_pref("services.sync.prefs.sync-seen.app.shield.optoutstudies.enabled", false);
