{ config, pkgs, lib, inputs,... }:
let
	# fox_containeers = {
	# 	dangerous = {
	# 		color = "red";
	# 		icon = "fruit";
	# 		id = 2;
	# 	};
	# 	normal = {
	# 		color = "blue";
	# 		icon = "cart";
	# 		id = 1;
	# 	};
	# };

in {
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "corvi";
  home.homeDirectory = "/Users/corvi";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "25.11"; # Please read the comment before changing.

  programs = {
    direnv.enable = true;
    direnv.nix-direnv.enable = true;
	zsh = {
		enable = true;
		initContent = ''
			if [ -f "$HOME/dotfiles/nix.zsh" ]; then
				source "$HOME/dotfiles/nix.zsh"
			else
				echo "Unable to source $HOME/dotfiles/nix.zsh"
			fi
		'';
		shellAliases = {
			darwin-switch="sudo darwin-rebuild switch --flake ~/dotfiles";
			darwin-check="sudo darwin-rebuild check --flake ~/dotfiles";
			home-switch="home-manager switch --flake ~/dotfiles/home-manager/#corvi";
			home-check="home-manager check --flake ~/dotfiles/home-manager/#corvi";

		};
	};
	firefox = {
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
	};
  };
  xdg = {
    configFile = {
     "wezterm" = {
          source = config.lib.file.mkOutOfStoreSymlink "/Users/corvi/dotfiles/wezterm";
          recursive = true;
      };
      "aerospace" = {
        source = config.lib.file.mkOutOfStoreSymlink "/Users/corvi/dotfiles/aerospace";
        recursive = true;
      };
      "nvim" = {
        source = config.lib.file.mkOutOfStoreSymlink "/Users/corvi/dotfiles/nvim";
        recursive = true;
      };
      "tmux" = {
        source = config.lib.file.mkOutOfStoreSymlink "/Users/corvi/dotfiles/tmux";
        recursive = true;
      };
      "ghostty" = {
        source = config.lib.file.mkOutOfStoreSymlink "/Users/corvi/dotfiles/ghostty";
        recursive = true;
      };
    };
  };
  
  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    wget
    pyenv
    k9s
    neovim

    # deps for python
    gcc
    gnumake
    zlib
    libffi
    readline
    bzip2
    openssl
	awscli2
    ghostty-bin
  ] ++ lib.optionals pkgs.stdenv.isDarwin [
    pkgs.cocoapods
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/corvi/etc/profile.d/hm-session-vars.sh
  #
  home.sessionPath = [
	"$HOME/.nix-profile/bin"
  ];
  home.sessionVariables = {
    # EDITOR = "emacs";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
