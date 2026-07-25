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
    nodejs_24
  ];
}
