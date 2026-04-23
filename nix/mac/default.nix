{ pkgs, inputs, ... }:

{
  imports = [
    ../dev.nix
    ../base.nix
  ];
  environment.systemPackages = with pkgs; [
    utm
  ];
  nix-homebrew = {
    enable = true;
    enableRosetta = true;
    user = "corvi";
    taps = {
      "homebrew/homebrew-core" = inputs.homebrew-core;
      "homebrew/homebrew-cask" = inputs.homebrew-cask;
      "nikitabobko/AeroSpace" = inputs.aerospace;
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
  security.pam.services.sudo_local = {
    enable = true;
    touchIdAuth = true;
    reattach = true;
  };
  nixpkgs.hostPlatform = "aarch64-darwin";
  nixpkgs.config.allowUnfree = true;
  system = {
    configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;

    # Used for backwards compatibility, please read the changelog before changing.
    # $ darwin-rebuild changelog
    stateVersion = 6;
    primaryUser = "corvi";
    startup.chime = false;
    defaults = {
      dock = {
        autohide = true;
        persistent-others = [ ];
      };
      finder = {
        AppleShowAllExtensions = true;
        AppleShowAllFiles = true;
      };
    };
  };

}
