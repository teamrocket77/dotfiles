{
  description = "Example nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-25.11-darwin";
    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-25.11";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager = {
        url = "github:nix-community/home-manager/release-25.11";
        inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    homebrew-core = {
       url = "github:homebrew/homebrew-core";
       flake = false;
    };
    homebrew-cask = {
       url = "github:homebrew/homebrew-cask";
       flake = false;
    };
    # Brew taps
    aerospace = {
	url = "github:nikitabobko/AeroSpace";
	flake = false;
    };
    # pinned packages
    wezterm.url = "github:wezterm/wezterm/dd6e5bd2f492c8f710f569fe1d17c9cffb2b0821?dir=nix";
    neovim.url = "github:NixOs/nixpkgs/73a57bd";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew, homebrew-core, homebrew-cask, aerospace, wezterm, home-manager, neovim}:
  let
	brew = {
		nix-homebrew = {
			enable = true;
			enableRosetta = true;
			user = "corvi";
			taps = {
				"homebrew/homebrew-core" = homebrew-core;
				"homebrew/homebrew-cask" = homebrew-cask;
				"nikitabobko/AeroSpace" = aerospace;
			};
		};
		homebrew = {
			enable = true;
			brews = [
				{ name = "minikube"; }
				{ name = "container"; }
				{ name = "helm"; }
				{ name = "kubeconform"; }
				{ name = "qemu"; }

			];
			casks = [
				{ name = "nikitabobko/tap/aerospace"; }
				{ name = "docker-desktop"; }
				{ name = "rectangle"; }
				{ name = "little-snitch"; }
				{ name = "brave-browser"; }
				{ name = "flux-app"; }
			];

		};

	};
    	home-config = {pkgs, config, ...}: {
		home-manager = {
			useGlobalPkgs = true;
			useUserPackages = true;
			users.corvi = {pkgs, config, ...}: {
				home.stateVersion = "25.11";
				xdg.configFile."wezterm" = {
					source = config.lib.file.mkOutOfStoreSymlink "/Users/corvi/dotfiles/wezterm";
					recursive = true;
				};
				xdg.configFile."aerospace" = {
					source = config.lib.file.mkOutOfStoreSymlink "/Users/corvi/dotfiles/aerospace";
					recursive = true;
				};
				xdg.configFile."nvim" = {
					source = config.lib.file.mkOutOfStoreSymlink "/Users/corvi/dotfiles/nvim";
					recursive = true;
				};
				xdg.configFile."tmux" = {
					source = config.lib.file.mkOutOfStoreSymlink "/Users/corvi/dotfiles/tmux";
					recursive = true;
				};
			};
		};
	};
    configuration = { pkgs, ... }: {

      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages = with pkgs; [ 
	wezterm.packages.${pkgs.system}.default
    neovim.legacyPackages.${pkgs.system}.neovim
	gnupg
	rustc
	tree
	cargo
    obsidian
	ripgrep
	zoxide
	nixfmt
	utm
	nodejs_24
        ];

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";
      users.users.corvi = {
	shell = pkgs.zsh;
	home = "/Users/corvi";
	};

      # Enable alternative shell support in nix-darwin.
      # programs.fish.enable = true;

      # Set Git commit hash for darwin-version.
      security.pam.services.sudo_local = {
		enable = true;
		touchIdAuth = true;
		reattach = true;
	};
      system = {
	      configurationRevision = self.rev or self.dirtyRev or null;

	      # Used for backwards compatibility, please read the changelog before changing.
	      # $ darwin-rebuild changelog
	      stateVersion = 6;
	      primaryUser = "corvi";
	      startup.chime = false;
	      defaults = {
		dock = {
			autohide = true;
			persistent-others = [];
		};
                finder = {
                    AppleShowAllExtensions = true;
                    AppleShowAllFiles = true;
                };
          };
      };

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";
      nixpkgs.config.allowUnfree = true;
      programs = {
        zsh = {
		enable = true;
		histSize = 10000;
		interactiveShellInit = ''
		if [ -f "$HOME/dotfiles/nix.zsh" ]; then
			source "$HOME/dotfiles/nix.zsh"
		else
			echo "Unable to source $HOME/dotfiles/nix.zsh"
		fi
		alias darwin-switch='sudo darwin-rebuild switch --flake ~/dotfiles'
		alias darwin-check='sudo darwin-rebuild check --flake ~/dotfiles'
		'';
        };
	gnupg.agent = {
		enable = true;
		enableSSHSupport = true;
	};
	tmux = {
		enable = true;
		enableVim = true;
		extraConfig = ''
			set -g default-terminal "xterm-256color"
			set -g prefix C-a
			set -g base-index 1
			set -g history-limit 50000
			set -g display-time 1000
			set -s escape-time 200

			# setw pane-base-index 1
			setw -g mode-keys vi

			set-option -a terminal-overrides ",alacritty:RGB"
			set-option -g repeat-time 100
			set-option -g mouse on
			set-option -g status-position top
			set-option -s set-clipboard off
			set -g pane-border-style fg=brightblack,bg=black
			set -g pane-active-border-style fg=blue,bg=black
			set-window-option -g window-active-style bg=terminal
			set-window-option -g window-style bg=black

			unbind C-b
			unbind % 
			unbind '"'
			unbind h 
			unbind j 
			unbind k 
			unbind l 
			unbind s 
			unbind t 

			bind-key C-a send-prefix

			bind | split-window -h -c "#{pane_current_path}"
			bind - split-window -v -c "#{pane_current_path}"
			bind c new-window -c "#{pane_current_path}"
			bind P paste-buffer
			bind -r h select-pane -L
			bind -r j select-pane -D
			bind -r k select-pane -U
			bind -r l select-pane -R
			bind M-s popup -xC -yC -w70% -h70% -E "tmux new -A -s sratch"
			bind s split-window -v "tmux list-sessions | sed -E 's/:.*$//' | grep -v \"^$(tmux display-message -p '#S')\$\" | fzf --reverse | xargs tmux switch-client -t"
			bind w split-window -v "tmux list-windows | sed -E 's/:.*$//' | grep -v \"^$(tmux display-message -p '#S')\$\" | fzf --reverse | xargs tmux select-window -t"
		'';
	};
	};
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#vice
	# must use scutil to rename pref options: ComputerName, LocalHostName, HostName
    darwinConfigurations."vice" = nix-darwin.lib.darwinSystem {
      modules = [ 
	configuration
	brew
	home-config
	./nix/vim.nix
	./nix/mac.nix

	nix-homebrew.darwinModules.nix-homebrew
	home-manager.darwinModules.home-manager
      ];
    };
  };
}
