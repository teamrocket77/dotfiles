{pkgs, ...}:
{
  enable = true;
  policies = {
    DisableTelemetry = true;
    DNSOverHTTPS = {
      Enabled = true;
      Fallback = false;
      ProviderURL = "https://dns.quad9.net/dns-query";
    };
    EnableTrackingProtection = {
      Category = "strict";
      Cryptomining = true;
      EmailTracking = true;
      Fingerprinting = true;
      SuspectedFingerprinting = true;
      Value = true;
    };
    ExtensionSettings = {
      "ublockOrigin" = {
        installation_mode = "normal_installed";
        install_url = "https://addons.mozilla.org/firefox/downloads/file/4721638/ublock_origin-1.70.0.xpi";
        private_browsing = true;
      };
    };
    FirefoxHome = {
      Highlights = false;
      Search = false;
      SponsoredStories = false;
      SponsoredTopSites = false;
      Stories = false;
      TopSites = true;
    };
    FirefoxSuggest = {
      ImproveSuggest = false;
      SponsoredSuggestions = false;
      WebSuggestions = false;
    };
    HttpsOnlyMode = true;
    NetworkPrediction = false;
    NoDefaultBookmarks = true;
    PasswordManagerEnabled = false;
    profiles = {
    };
    Permissions = {
      Autoplay.Default = "block-audio";
      Camera.BlockNewRequests = true;
      Location.BlockNewRequests = true;
      Microphone.BlockNewRequests = true;
      Notifications.BlockNewRequests = true;
      ScreenShare.BlockNewRequests = true;
      VirtualReality.BlockNewRequests = true;
    };
    PictureInPicture.Enabled = true;
    PopupBlocking.Default = true;
    PostQuantumKeyAgreementEnabled = true;
    RequestedLocales = "en-US";
    SanitizeOnShutdown = {
      Cache = true;
      Downloads = true;
      FormData = true;
    };
    SearchEngines.Add = [
      {
        Name = "Docker Hub";
        Alias = "@dh";
        URLTemplate = "https://hub.docker.com/search?q={searchTerms}";
        IconURL = "https://hub.docker.com/favicon.ico";
      }
      {
        Name = "GitHub";
        Alias = "@gh";
        URLTemplate = "https://github.com/search?q={searchTerms}";
        IconURL = "https://github.com/favicon.ico";
      }
      {
        Name = "GitHub Nix";
        Alias = "@gn";
        URLTemplate = "https://github.com/search?q=language%3ANix+NOT+is%3Afork+{searchTerms}&type=code";
        IconURL = "https://github.com/favicon.ico";
      }
      {
        Name = "Home Manager";
        Alias = "@hm";
        URLTemplate = "https://home-manager-options.extranix.com/?query={searchTerms}&release=release-25.11";
        IconURL = "https://home-manager-options.extranix.com/images/favicon.png";
      }
      {
        Name = "NixOS Options";
        Alias = "@no";
        URLTemplate = "https://search.nixos.org/options?channel=25.11&query={searchTerms}";
        IconURL = "https://search.nixos.org/favicon.png";
      }
      {
        Name = "NixOS Packages";
        Alias = "@np";
        URLTemplate = "https://search.nixos.org/packages?channel=25.11&query={searchTerms}";
        IconURL = "https://search.nixos.org/favicon.png";
      }
      {
        Name = "NixOS Wiki";
        Alias = "@nw";
        URLTemplate = "https://wiki.nixos.org/w/index.php?search={searchTerms}";
        IconURL = "https://wiki.nixos.org/favicon.ico";
      }
      {
        Name = "Reddit";
        Alias = "@rd";
        URLTemplate = "https://www.reddit.com/search/?q={searchTerms}";
        IconURL = "https://www.reddit.com/favicon.ico";
      }
      {
        Name = "Stack Overflow";
        Alias = "@so";
        URLTemplate = "https://stackoverflow.com/search?q={searchTerms}";
        IconURL = "https://stackoverflow.com/favicon.ico";
      }
      {
        Name = "Steam";
        Alias = "@st";
        URLTemplate = "https://store.steampowered.com/search?term={searchTerms}";
        IconURL = "https://store.steampowered.com/favicon.ico";
      }
      {
        Name = "Wikipedia";
        Alias = "@wk";
        URLTemplate = "https://en.wikipedia.org/wiki/Special:Search?search={searchTerms}";
        IconURL = "https://en.wikipedia.org/static/favicon/wikipedia.ico";
      }
      {
        Name = "Wolfram Alpha";
        Alias = "@wa";
        URLTemplate = "https://www.wolframalpha.com/input?i={searchTerms}";
        IconURL = "https://www.wolframalpha.com/_next/static/images/favicon_b48d893b991ff67016124a4d51822e63.ico";
      }
      {
        Name = "YouTube";
        Alias = "@yt";
        URLTemplate = "https://www.youtube.com/results?search_query={searchTerms}";
        IconURL = "https://www.youtube.com/favicon.ico";
      }
    ];
    SearchEngines.Remove = [
      "Amazon.com"
      "Bing"
      "eBay"
      "Perplexity"
      "Wikipedia (en)"
    ];
    SearchSuggestEnabled = false;
    ShowHomeButton = true;
    SkipTermsOfUse = true;
    UserMessaging = {
      ExtensionRecommendations = false;
      FeatureRecommendations = false;
      UrlbarInterventions = false;
      SkipOnboarding = true;
      MoreFromMozilla = false;
      FirefoxLabs = false;
    };
  };
}
