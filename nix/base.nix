{ pkgs, ... }:
{
  nix = {
    gc = {
      automatic = true;
      interval = { Day = 3; };
      options = "--delete-older-than 30d";
    };
    optimise = {
        automatic = true;
        interval = { Day = 30; };
    };
    settings = {
        substituters = [ "https://cache.nixos.org/" ];
        min-free = 5 * 1024 * 1024 * 1024;
        max-free = 10 * 1024 * 1024 * 1024; 
    };
  };
  documentation = {
      enable = true;
      man.enable = true;
  };
  environment.systemPackages = with pkgs; [
    ((vim-full.override { }).customize {
      name = "vim";
      vimrcConfig.packages.myplugins = with vimPlugins; {
        start = [
          vim-nix
          vim-lastplace
          ale
          coc-sh
          coc-yaml
        ];
        opt = [ ];
      };
      vimrcConfig.customRC = ''
        		 set nocompatible
        		 syntax on
        		 set nu rnu hlsearch belloff=all
        		 set mouse=a
        		 autocmd FileType yaml setlocal expandtab tabstop=2 shiftwidth=2 softtabstop autoindent
        		 autocmd FileType yaml setlocal indentkeys-=0#
                 " autocmd FileType nix setlocal tabstop=2 shiftwidth=2
        		 filetype plugin indent on
        		 '';
    })
    nixfmt
    nixfmt-tree
    tmux

  ];
  programs = {
    tmux = {
      enable = true;
      enableVim = true;
      extraConfig = ''
                source-file ~/.config/tmux/tmux.conf
       '';
    };
  };
}
