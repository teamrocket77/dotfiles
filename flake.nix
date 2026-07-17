{
  description = "Example nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";
    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    # home-manager = {
    #   url = "github:nix-community/home-manager/release-25.11";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

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
    mac-app-util.url = "github:hraban/mac-app-util";
  };

  outputs =
    inputs@{
      self,
      nix-darwin,
      nixpkgs,
      nix-homebrew,
      homebrew-core,
      homebrew-cask,
      wezterm,
      # home-manager,
      aerospace,
	  mac-app-util,
    }:
    let
      configuration = { pkgs, ... }:
        {
          # Necessary for using flakes on this system.
          nix.settings.experimental-features = "nix-command flakes";
		  nix.gc = {
			  automatic = true;
			  interval = {
				  Weekday = 7;
				  Hour = 8;
				  Minute = 0;
			  };
		  };
		  nixpkgs.overlays = [
		  ];

          # Enable alternative shell support in nix-darwin.
          # programs.fish.enable = true;

          # Set Git commit hash for darwin-version.

          # The platform the configuration will be used on.
		  environment.shellAliases = {
			darwin-switch="sudo darwin-rebuild switch --flake ~/dotfiles";
			darwin-check="sudo darwin-rebuild check --flake ~/dotfiles";
			g="git";
		  };
          programs = {
            zsh = {
              enable = true;
              histSize = 10000;
            };
            gnupg.agent = {
              enable = true;
              enableSSHSupport = true;
            };
          };
        };
    in
    {
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#vice
      # must use scutil to rename pref options: ComputerName, LocalHostName, HostName
      darwinConfigurations."vice" = nix-darwin.lib.darwinSystem {
		specialArgs = { inherit inputs; };
        modules = [
          configuration
          ./nix/mac
          nix-homebrew.darwinModules.nix-homebrew
        ];
      };
    };
}
