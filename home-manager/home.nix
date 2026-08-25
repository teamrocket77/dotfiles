{ config, pkgs, lib, inputs,... }:
let
        ffSettings = import ./firefox.nix { inherit pkgs; };
        zshSettings = import ./zsh.nix { inherit pkgs; };
        xdgSettings = import ./xdg-config.nix {inherit pkgs config; };
in {
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "corvi";
  home.homeDirectory = "/Users/corvi";
  home.stateVersion = "25.11"; # Please read the comment before changing.

  programs = {
    direnv.enable = true;
    direnv.nix-direnv.enable = true;
    zsh = zshSettings;
    firefox = ffSettings;
    pandoc = {
      enable = true;
    };
  };
  xdg = xdgSettings;
  
  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    wezterm
    wget
    pyenv
    k9s
    neovim
    kitty

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
    fzf
  ] ++ lib.optionals pkgs.stdenv.isDarwin [
    pkgs.cocoapods
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
      ".terminfo/77/wezterm".source = "${pkgs.wezterm.terminfo}/share/terminfo/77/wezterm";
  };
  home.sessionPath = [
	"$HOME/.nix-profile/bin"
  ];
  home.sessionVariables = {
    # EDITOR = "emacs";

  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
