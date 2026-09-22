# Template for ~/.zshenv on non-Nix (work) machines.
# ~/.zshenv is read by EVERY zsh invocation (interactive, `zsh -c`, scripts,
# cron), so this is where env vars, PATH, and functions must load — otherwise
# non-interactive shells (e.g. nvim's :! / system()) can't see them.
#
# Copy the snippet below into ~/.zshenv (alongside whatever else lives there,
# e.g. the cargo env line). The interactive half is sourced separately from
# ~/.zshrc via work-init.sh (shell/rc/*).
if [[ -d "$HOME/.config/shell/env" ]]; then
    for f in "$HOME"/.config/shell/env/*(.N); do source "$f"; done
fi
