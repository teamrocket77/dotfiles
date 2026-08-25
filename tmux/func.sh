#!/usr/bin/env bash

TMUX_PLUGIN_DIR="$HOME/.tmux/plugins"

check-dir(){
  local DIR_TO_CHECK=$1
  if [[ -d "$DIR_TO_CHECK" ]]; then
    return 0
  fi
  return 1
}

check-tmux-plugins-dir(){
  if check-dir "$TMUX_PLUGIN_DIR"; then
    return 0
  else
    mkdir -p "$TMUX_PLUGIN_DIR"
    check-dir "$TMUX_PLUGIN_DIR" # return value implied
  fi
}

clone-tmux-plugin(){
  local PLUGIN_DIR=$1
  local PLUGIN_REPO=$2
  echo "cloning repo: $PLUGIN_REPO"
  git clone "$2" "$1"
  echo "done cloning repo: $PLUGIN_REPO"
}

download-tmux-plugin(){
  echo "starting custom tmux plugin manager"
  local PLUGIN_DIR=$1
  local PLUGIN_REPO=$2

  check-tmux-plugins-dir
  clone-tmux-plugin "$PLUGIN_DIR" "$PLUGIN_REPO"
  echo "ending custom tmux plugin manager"
}
