# Pure-safe, on-demand RPROMPT context indicators.
#
# While you type a matching command, a small token is appended to Pure's
# RPROMPT and removed again as soon as the command no longer matches:
#   kubectl / k …  -> ⎈ [A] <cluster>   (cyan)   current kube cluster
#   python / pip … -> [P] <version>      (yellow) pyenv version or active venv
#   aws …          -> [A] <profile>      (orange) $AWS_PROFILE
#
# All lookups are cheap file/env reads refreshed once per prompt (precmd);
# nothing shells out to kubectl/pyenv/aws.
#
# Self-contained on purpose: this file is sourced by work-init.sh before
# ~/.zshrc autoloads these, so we autoload them here too (idempotent).
autoload -Uz add-zsh-hook add-zle-hook-widget

# 1. Kube context — read ~/.kube/config directly instead of running kubectl.
function _update_kube_cache() {
  local kubeconfig="${KUBECONFIG:-$HOME/.kube/config}"
  local ctx=""
  if [[ -f "$kubeconfig" ]]; then
    # Grab the current context line instantly
    ctx=$(grep -m 1 '^current-context:' "$kubeconfig" 2>/dev/null | awk '{print $2}')
  fi

  if [[ -z "$ctx" ]]; then
    _CACHED_KUBE_CTX=""
    return
  fi

  # AWS EKS contexts are full ARNs, e.g.
  #   arn:aws-us-gov:eks:us-gov-west-1:732461764173:cluster/dev-ml
  # Show "[A] <cluster>" for those; otherwise use the raw context name.
  if [[ "$ctx" == arn:aws* ]]; then
    _CACHED_KUBE_CTX="[A] ${ctx##*cluster/}"
  else
    _CACHED_KUBE_CTX="$ctx"
  fi
}
add-zsh-hook precmd _update_kube_cache

# 1b. Same idea for Python: cheap file reads only, no subprocess.
function _update_python_cache() {
  # An active virtualenv wins — show its name.
  if [[ -n "$VIRTUAL_ENV" ]]; then
    _CACHED_PY_CTX="${VIRTUAL_ENV:t}"
    return
  fi

  # A `pyenv shell` override.
  if [[ -n "$PYENV_VERSION" ]]; then
    _CACHED_PY_CTX="$PYENV_VERSION"
    return
  fi

  # Walk up for a local .python-version, like pyenv does.
  local dir="$PWD"
  while true; do
    if [[ -f "$dir/.python-version" ]]; then
      _CACHED_PY_CTX=$(head -n 1 "$dir/.python-version" 2>/dev/null)
      return
    fi
    [[ "$dir" == "/" ]] && break
    dir="${dir:h}"
  done

  # Fall back to the pyenv global version.
  if [[ -f "$PYENV_ROOT/version" ]]; then
    _CACHED_PY_CTX=$(head -n 1 "$PYENV_ROOT/version" 2>/dev/null)
  else
    _CACHED_PY_CTX=""
  fi
}
add-zsh-hook precmd _update_python_cache

# 1c. AWS profile — just the env var, no subprocess.
function _update_aws_cache() {
  _CACHED_AWS_CTX="${AWS_PROFILE:-default}"
}
add-zsh-hook precmd _update_aws_cache

# 2. The Pure-safe typing hook — handles kube (⎈), python ([P]) and aws ([A]).
function _pure_context_on_type() {
  local kube_str="" py_str="" aws_str=""
  [[ -n "$_CACHED_KUBE_CTX" ]] && kube_str="%F{cyan}⎈ ${_CACHED_KUBE_CTX}%f"
  [[ -n "$_CACHED_PY_CTX" ]]   && py_str="%F{yellow}[P] ${_CACHED_PY_CTX}%f"
  [[ -n "$_CACHED_AWS_CTX" ]]  && aws_str="%F{214}[A] ${_CACHED_AWS_CTX}%f"

  # Strip our tokens out of RPROMPT to preserve Pure's async Git/Time updates.
  local base="$RPROMPT"
  [[ -n "$kube_str" ]] && base="${base// $kube_str/}"
  [[ -n "$py_str" ]]   && base="${base// $py_str/}"
  [[ -n "$aws_str" ]]  && base="${base// $aws_str/}"

  # Append each token only while typing a matching command.
  local extra=""
  if [[ -n "$kube_str" ]] && { [[ "$BUFFER" == kubectl\ * ]] || [[ "$BUFFER" == k\ * ]] || [[ "$BUFFER" == helm\ * ]]; }; then
    extra="${extra} ${kube_str}"
  fi
  if [[ -n "$py_str" ]] && [[ "$BUFFER" == (python|python3|pip|pip3|py|uv|poetry|pytest)\ * ]]; then
    extra="${extra} ${py_str}"
  fi
  if [[ -n "$aws_str" ]] && [[ "$BUFFER" == aws\ * ]]; then
    extra="${extra} ${aws_str}"
  fi

  RPROMPT="${base}${extra}"

  # Redraw the line seamlessly
  zle .reset-prompt 2>/dev/null
}

# 3. Register the typing hook
zle -N _pure_context_on_type
add-zle-hook-widget line-pre-redraw _pure_context_on_type

# 4. Clear our tokens at the start of every new prompt.
#
# The typing hook above only removes tokens while you are editing a line, so
# after you press enter the indicator can linger on the fresh prompt. Stripping
# in precmd guarantees each new prompt starts clean — the token reappears only
# once you start typing a matching command again. Registered last so it runs
# after the cache-update precmd hooks and sees the current cached values.
function _pure_context_reset() {
  local kube_str="%F{cyan}⎈ ${_CACHED_KUBE_CTX}%f"
  local py_str="%F{yellow}[P] ${_CACHED_PY_CTX}%f"
  local aws_str="%F{214}[A] ${_CACHED_AWS_CTX}%f"

  local base="$RPROMPT"
  [[ -n "$_CACHED_KUBE_CTX" ]] && base="${base// $kube_str/}"
  [[ -n "$_CACHED_PY_CTX" ]]   && base="${base// $py_str/}"
  [[ -n "$_CACHED_AWS_CTX" ]]  && base="${base// $aws_str/}"

  RPROMPT="$base"
}
add-zsh-hook precmd _pure_context_reset
