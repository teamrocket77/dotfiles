#!/usr/bin/env zsh

# cannot use -eu b/c the shell plugin scripts fail
# might fork idk rn

set -E

TRAPZERR() {
  local last_caller="${funcfiletrace[1]}"
  
  # Ignore errors originated from prompt plugins or interactive line redraws
  if [[ "$last_caller" == *pure* || "$last_caller" == *prompt_* ]]; then
    return 0
  fi

  local exit_code=$?
  echo "[ERR TRAP] Error code $exit_code occurred!" >&2
  echo "Stack trace:" >&2
  local frame
  for frame in "${funcfiletrace[@]}"; do
    echo "  -> at $frame" >&2
  done

  return 0
}

if [[ -d "$HOME/dotfiles/shell" ]]; then
    for F in ~/dotfiles/shell/*(.N); do
		source $F
    done
fi

export PATH="$HOME/.local/bin:$PATH"
