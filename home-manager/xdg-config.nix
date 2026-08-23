{pkgs, config, ...}:
{
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
    "kitty" = {
      source = config.lib.file.mkOutOfStoreSymlink "/Users/corvi/dotfiles/kitty";
      recursive = true;
    };
    "alacritty" = {
      source = config.lib.file.mkOutOfStoreSymlink "/Users/corvi/dotfiles/alacritty";
      recursive = true;
    };
  };
}
