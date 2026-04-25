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

  outputs =
    inputs@{
      self,
      nix-darwin,
      nixpkgs,
      nix-homebrew,
      homebrew-core,
      homebrew-cask,
      aerospace,
      wezterm,
      home-manager,
      neovim,
    }:
    let
      home-config =
        { pkgs, config, ... }:
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.corvi =
              { pkgs, config, ... }:
              {
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
      configuration =
        { pkgs, ... }:
        {

          # List packages installed in system profile. To search by name, run:
          # $ nix-env -qaP | grep wget

          # Necessary for using flakes on this system.
          nix.settings.experimental-features = "nix-command flakes";
          users.users.corvi = {
            shell = pkgs.zsh;
            home = "/Users/corvi";
          };

          # Enable alternative shell support in nix-darwin.
          # programs.fish.enable = true;

          # Set Git commit hash for darwin-version.

          # The platform the configuration will be used on.
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
          home-config
          ./nix/mac

          nix-homebrew.darwinModules.nix-homebrew
          home-manager.darwinModules.home-manager
        ];
      };
    };
}
