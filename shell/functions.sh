get-wifi-pw(){
	security find-generic-password -wga $1
}

get-cover-pdf(){
if (( $+commands[pandoc])); then
	if ! [ -f "./cltemplate.tex" ]; then
	  echo "$PWD"
	  echo "the template file doesn't exist"
	else
	  pandoc --pdf-engine=xelatex \
	  --template=./cltemplate.tex \
	  -p -f markdown \
	  -t latex \
	  -s $1 \
	  -o cover.pdf 
	  echo "Done"
	fi
else
	echo "pandoc command does not exist"
fi
}

if (( $+commands[terminal-notifier] )); then
	notify(){
		terminal-notifier -title $1 -message $2
	}

	py-notify(){
		notify "Python" $1
	}

	Py-notify(){
		notify "Python" $1
	}

fi
set-title(){
    echo -e "\033]0;$1\007"
}
source-help(){
}

fman() {
    local page
    local search_term="."
    
    local fzf_opts=(--tiebreak=begin)
    local prompt="Man (All)> "

    if [[ "$1" == "-c" ]]; then
        fzf_opts=(--tiebreak=begin --delimiter=- --nth=1)
        prompt="Man (Cmd)> "
        shift 
    fi
    
    if [[ -n "$1" ]]; then
        search_term="$1"
    fi
    
    page=$(apropos "$search_term" | awk '{print length($1), $0}' | sort -n | cut -d" " -f2- | fzf --prompt="$prompt" "${fzf_opts[@]}" \
        --preview="echo {} | awk -F ' - ' '{print \$1}' | awk -F ',' '{print \$1}' | sed -E 's/^([^[:space:](]+)[[:space:]]*\(([^)]+)\).*/\2 \1/' | xargs man" \
        --preview-window=right:60%)

    # If a page was selected, run the exact same pipeline from the preview window
    # but pipe it straight into xargs man!
    if [[ -n "$page" ]]; then
        echo "$page" | awk -F ' - ' '{print $1}' | awk -F ',' '{print $1}' | sed -E 's/^([^[:space:](]+)[[:space:]]*\(([^)]+)\).*/\2 \1/' | xargs man
    fi
}

# Branch stack — pushd/popd, but for git branches.
#   gpush <branch> : remember the current branch, then checkout <branch>.
#   gpop           : checkout the most recently remembered branch, popping it.
#   gbstack        : show the stack (top first).
typeset -ga GIT_BRANCH_STACK

# True (exit 0) if the working tree has *tracked* changes. `git status
# --porcelain` prefixes untracked files with '??'; we drop those and treat any
# remaining line (M, A, D, R, ...) as a real change worth guarding against.
_git_tracked_dirty() {
	git status --porcelain 2>/dev/null | grep -qv '^??'
}

gpush() {
	local target="$1"
	if [[ -z "$target" ]]; then
		echo "gpush: usage: gpush <branch>" >&2
		return 1
	fi
	local current
	current=$(git symbolic-ref --short -q HEAD) || {
		echo "gpush: not on a branch (detached HEAD?)" >&2
		return 1
	}
	if _git_tracked_dirty; then
		echo "gpush: tracked changes present — commit or stash first" >&2
		return 1
	fi
	git checkout "$target" || return 1
	GIT_BRANCH_STACK+=("$current")
	echo "gpush: stacked $current (depth ${#GIT_BRANCH_STACK})"
}

gpop() {
	if (( ${#GIT_BRANCH_STACK} == 0 )); then
		echo "gpop: branch stack is empty" >&2
		return 1
	fi
	if _git_tracked_dirty; then
		echo "gpop: tracked changes present — commit or stash first" >&2
		return 1
	fi
	local target="${GIT_BRANCH_STACK[-1]}"
	git checkout "$target" || return 1
	GIT_BRANCH_STACK[-1]=()  # pop the top
	echo "gpop: back on $target (depth ${#GIT_BRANCH_STACK})"
}

gbstack() {
	if (( ${#GIT_BRANCH_STACK} == 0 )); then
		echo "branch stack: (empty)"
		return 0
	fi
	local i
	for (( i = ${#GIT_BRANCH_STACK}; i >= 1; i-- )); do
		echo "  $i: ${GIT_BRANCH_STACK[$i]}"
	done
}
