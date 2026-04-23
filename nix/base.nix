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
    nixfmt
    nixfmt-tree

  ];
  programs = {
    tmux = {
      enable = true;
      enableVim = true;
      extraConfig = ''
        			set -g default-terminal "xterm-256color"
        			set -g prefix C-a
        			set -g base-index 1
        			set -g history-limit 50000
        			set -g display-time 1000
        			set -s escape-time 200

        			# setw pane-base-index 1
        			setw -g mode-keys vi

        			set-option -a terminal-overrides ",alacritty:RGB"
        			set-option -g repeat-time 100
        			set-option -g mouse on
        			set-option -g status-position top
        			set-option -s set-clipboard off
        			set -g pane-border-style fg=brightblack,bg=black
        			set -g pane-active-border-style fg=blue,bg=black
        			set-window-option -g window-active-style bg=terminal
        			set-window-option -g window-style bg=black

        			unbind C-b
        			unbind % 
        			unbind '"'
        			unbind h 
        			unbind j 
        			unbind k 
        			unbind l 
        			unbind s 
        			unbind t 

        			bind-key C-a send-prefix

        			bind | split-window -h -c "#{pane_current_path}"
        			bind - split-window -v -c "#{pane_current_path}"
        			bind c new-window -c "#{pane_current_path}"
        			bind P paste-buffer
        			bind -r h select-pane -L
        			bind -r j select-pane -D
        			bind -r k select-pane -U
        			bind -r l select-pane -R
        			bind M-s popup -xC -yC -w70% -h70% -E "tmux new -A -s sratch"
        			bind s split-window -v "tmux list-sessions | sed -E 's/:.*$//' | grep -v \"^$(tmux display-message -p '#S')\$\" | fzf --reverse | xargs tmux switch-client -t"
        			bind w split-window -v "tmux list-windows | sed -E 's/:.*$//' | grep -v \"^$(tmux display-message -p '#S')\$\" | fzf --reverse | xargs tmux select-window -t"
        		'';
    };
  };
}
