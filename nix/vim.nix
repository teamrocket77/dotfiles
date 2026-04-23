{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    ((vim-full.override { }).customize {
      name = "vim";
      vimrcConfig.packages.myplugins = with vimPlugins; {
        start = [
          vim-nix
          vim-lastplace
          ale
          coc-go
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
        		 filetype plugin indent on
        		 '';
    })
  ];
}
