{ pkgs, inputs, ... }:
{
  environment.systemPackages = with pkgs; [
    inputs.wezterm.packages.${pkgs.system}.default
    inputs.neovim.legacyPackages.${pkgs.system}.neovim
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
