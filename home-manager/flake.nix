{
  description = "Home Manager configuration of corvi";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-26.05-darwin";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
	ffox-addons = {
		url = "gitlab:rycee/nur-expressions";
		inputs.nixpkgs.follows = "nixpkgs";
	};
  };

  outputs = { nixpkgs, home-manager, ffox-addons,... }@inputs:
    let
      system = "aarch64-darwin";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      homeConfigurations."corvi" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
		extraSpecialArgs = { inherit inputs; };

        # Specify your home configuration modules here, for example,
        # the path to your home.nix.
        modules = [ ./home.nix ];

        # Optionally use extraSpecialArgs
        # to pass through arguments to home.nix
      };
    };
}
