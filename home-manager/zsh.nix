{pkgs, ...}: 
{
  enable = true;
  enableCompletion = true;
  syntaxHighlighting.enable = true;
  # .zshenv: env vars, PATH, and functions (shell/env/*) for ALL zsh invocations,
  # incl. non-interactive `zsh -c` (nvim :!, system(), scripts). Mirrors the
  # ~/.zshenv snippet used on non-Nix machines (see zshenv.tmpl.sh).
  envExtra = ''
            if [[ -d "$HOME/dotfiles/shell/env" ]]; then
                for f in "$HOME"/dotfiles/shell/env/*(.N); do source "$f"; done
            fi
  '';
  # .zshrc: interactive-only setup (plugins, prompt, aliases, keybindings) via
  # nix.zsh → shell/rc/*.
  initContent = ''
            if [ -f "$HOME/dotfiles/nix.zsh" ]; then
                source "$HOME/dotfiles/nix.zsh"
            else
                echo "Unable to source $HOME/dotfiles/nix.zsh"
            fi
            autoload -Uz compinit
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
