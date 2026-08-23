{ pkgs, inputs, ... }:
{
  environment.systemPackages = with pkgs; [
    gnupg
    rustc
    tree
    cargo
    obsidian
    ripgrep
    zoxide
    utm
    zsh
    bash
    man-pages
    nodejs_24
  ];
}
