// Zen Browser user.js - Applied to all profiles
// Performance, UI preferences, and annoyance removal
// Last updated: 2025-01-20

// =============================================================================
// PERFORMANCE TWEAKS
// =============================================================================

// Faster page rendering
user_pref("gfx.webrender.all", true);
user_pref("gfx.webrender.enabled", true);
user_pref("layers.acceleration.force-enabled", true);

// Faster DNS
user_pref("network.dns.disablePrefetch", false);
user_pref("network.dns.disablePrefetchFromHTTPS", false);
user_pref("network.predictor.enabled", true);
user_pref("network.prefetch-next", true);

// Better caching
user_pref("browser.cache.disk.enable", true);
user_pref("browser.cache.memory.enable", true);
user_pref("browser.cache.memory.capacity", 524288); // 512MB memory cache

// Faster session restore
user_pref("browser.sessionstore.interval", 30000); // Save session every 30s instead of 15s
user_pref("browser.sessionstore.max_tabs_undo", 25);

// GPU acceleration
user_pref("media.ffmpeg.vaapi.enabled", true); // Hardware video decoding on Linux
user_pref("media.hardware-video-decoding.enabled", true);
user_pref("media.hardware-video-decoding.force-enabled", true);

// Reduce disk writes
user_pref("browser.sessionhistory.max_entries", 25);

// Faster tab switching
user_pref("browser.tabs.remote.autostart", true);
user_pref("browser.tabs.remote.autostart.2", true);

// =============================================================================
// UI PREFERENCES
// =============================================================================

// Bookmarks toolbar - always visible
user_pref("browser.toolbars.bookmarks.visibility", "always");

// Compact mode
user_pref("browser.compactmode.show", true);
user_pref("browser.uidensity", 1); // 0=normal, 1=compact, 2=touch

// Smoother scrolling
user_pref("general.smoothScroll", true);
user_pref("general.smoothScroll.msdPhysics.enabled", true);
user_pref("mousewheel.default.delta_multiplier_y", 275);

// Show full URLs
user_pref("browser.urlbar.trimURLs", false);
user_pref("browser.urlbar.trimHttps", false);

// Disable animations for snappier feel
user_pref("toolkit.cosmeticAnimations.enabled", false);

// New tab behavior
user_pref("browser.tabs.insertAfterCurrent", true);
user_pref("browser.tabs.loadBookmarksInTabs", true);

// Don't warn when closing multiple tabs
user_pref("browser.tabs.warnOnClose", false);
user_pref("browser.tabs.warnOnCloseOtherTabs", false);

// Restore previous session on startup
user_pref("browser.startup.page", 3);

// Disable about:config warning
user_pref("browser.aboutConfig.showWarning", false);

// Middle-click paste and go
user_pref("middlemouse.paste", true);

// =============================================================================
// DISABLE ANNOYANCES
// =============================================================================

// Disable Pocket
user_pref("extensions.pocket.enabled", false);
user_pref("extensions.pocket.api", "");
user_pref("extensions.pocket.site", "");

// Disable sponsored content
user_pref("browser.newtabpage.activity-stream.showSponsored", false);
user_pref("browser.newtabpage.activity-stream.showSponsoredTopSites", false);
user_pref("browser.newtabpage.activity-stream.feeds.topsites", false);

// Disable suggestions and recommendations
user_pref("browser.urlbar.suggest.quicksuggest.sponsored", false);
user_pref("browser.urlbar.suggest.quicksuggest.nonsponsored", false);
user_pref("browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons", false);
user_pref("browser.newtabpage.activity-stream.asrouter.userprefs.cfr.features", false);

// Disable Firefox/Zen studies and experiments
user_pref("app.shield.optoutstudies.enabled", false);
user_pref("messaging-system.rsexperimentloader.enabled", false);

// Disable default browser check
user_pref("browser.shell.checkDefaultBrowser", false);

// Disable "What's New" and update notifications
user_pref("browser.messaging-system.whatsNewPanel.enabled", false);
user_pref("browser.uitour.enabled", false);

// Disable form autofill (use Bitwarden instead)
user_pref("extensions.formautofill.addresses.enabled", false);
user_pref("extensions.formautofill.creditCards.enabled", false);

// Disable password manager (use Bitwarden instead)
user_pref("signon.rememberSignons", false);
user_pref("signon.autofillForms", false);
user_pref("signon.generation.enabled", false);

// Disable Firefox View
user_pref("browser.tabs.firefox-view", false);
user_pref("browser.tabs.firefox-view-next", false);

// Don't show translation popup
user_pref("browser.translations.automaticallyPopup", false);

// Disable captive portal detection
user_pref("network.captive-portal-service.enabled", false);

// Disable network connectivity check
user_pref("network.connectivity-service.enabled", false);

// Disable normandy (Mozilla remote settings)
user_pref("app.normandy.enabled", false);
user_pref("app.normandy.api_url", "");

// Disable crash reporter
user_pref("browser.crashReports.unsubmittedCheck.autoSubmit2", false);
user_pref("browser.crashReports.unsubmittedCheck.enabled", false);

// =============================================================================
// ZEN-SPECIFIC SETTINGS
// =============================================================================

// Compact mode at startup (hides sidebar)
user_pref("zen.view.compact.enable-at-startup", true);

// Use separate toolbars (not single toolbar)
user_pref("zen.view.use-single-toolbar", false);

// Enable workspaces
user_pref("zen.workspaces.enabled", true);

// Split view
user_pref("zen.splitView.enabled", true);
