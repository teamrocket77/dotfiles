{ pkgs, inputs, ... }:
{
  environment.systemPackages = with pkgs; [
    inputs.wezterm.packages.${stdenv.hostPlatform.system}.default
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
