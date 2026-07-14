{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
  };
  outputs  = { self, nixpkgs}:
  let
    system = "aarch64-darwin";
    pkgs = import nixpkgs { inherit system; };
  in
  {
    devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
            neovim
            python3
            opentofu
            ripgrep
            luarocks
            lua
        ];
        env = {
            XDG_CONFIG_HOME = ".";
            XDG_DATA_HOME = "/tmp/mason";
        };
        shellHook = ''
        mkdir -p ./.local
        '';
    };
  };
}
