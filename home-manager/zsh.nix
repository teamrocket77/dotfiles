{pkgs, ...}: 
{
  enable = true;
  enableCompletion = true;
  syntaxHighlighting.enable = true;
  initContent = ''
            if [ -f "$HOME/dotfiles/nix.zsh" ]; then
                source "$HOME/dotfiles/nix.zsh"
            else
                echo "Unable to source $HOME/dotfiles/nix.zsh"
            fi
            autoload -Uz compinit
            export HELPDIR="${pkgs.zsh}/share/zsh/${pkgs.zsh.version}/help"
  '';
  shellAliases = {
    darwin-switch="sudo darwin-rebuild switch --flake ~/dotfiles";
    darwin-check="sudo darwin-rebuild check --flake ~/dotfiles";
    home-switch="home-manager switch --flake ~/dotfiles/home-manager/#corvi";
    home-check="home-manager check --flake ~/dotfiles/home-manager/#corvi";

  };
  plugins = [
    {
      name = "pure";
      src = pkgs.fetchFromGitHub {
        owner = "sindresorhus";
        repo = "pure";
        rev = "v1.28.3";
        sha256 = "sha256-ZNi0ruTX9HRELXq1yvTm+StOuQ0UZgK6toMSgwqSD9A=";
      };
    }
  ];
}
