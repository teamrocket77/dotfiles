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

# Locate the pritunl-client binary (PATH first, then the app bundle). Echoes the
# path on success; prints an error and returns 1 if it can't be found.
_pritunl_cli() {
	local cli
	cli=$(command -v pritunl-client) \
		|| cli="/Applications/Pritunl.app/Contents/Resources/pritunl-client"
	if [[ ! -x "$cli" ]]; then
		echo "pritunl: pritunl-client not found" >&2
		return 1
	fi
	echo "$cli"
}

# Pritunl: remove every profile from the pritunl-client CLI store (inverse of
# pritunl-sync). Leaves the GUI's own profiles untouched.
pritunl-clear() {
	local cli
	cli=$(_pritunl_cli) || return 1
	local ids
	ids=($("$cli" list -j 2>/dev/null | grep -o '"id":"[^"]*"' | sed 's/"id":"//;s/"$//'))
	if (( ${#ids} == 0 )); then
		echo "pritunl-clear: no CLI profiles to remove"
		return 0
	fi
	local id
	for id in $ids; do
		echo "pritunl-clear: removing CLI profile $id"
		"$cli" remove "$id" >/dev/null
	done
}

# Pritunl: mirror the GUI's profiles into the pritunl-client CLI (one-way).
#
# The Electron GUI keeps profiles in ~/Library/Application Support/pritunl/profiles
# as <id>.ovpn + <id>.conf (the .conf holds the sync metadata). The CLI/service
# keeps a separate store and won't see GUI profiles. `pritunl-sync` wipes every CLI
# profile, then re-imports each GUI profile so the CLI mirrors the GUI — after which
# `pritunl-client list/start/stop` work from the shell.
#
# The CLI's `add` only accepts a tar of .ovpn files whose sync conf is embedded as
# #-prefixed lines wrapped in `#{` ... `#}`. So per profile we splice the .conf JSON
# into the .ovpn, tar it, and add it. COPYFILE_DISABLE=1 stops macOS tar from adding
# ._ AppleDouble members, which the importer rejects (aborting on the first member).
pritunl-sync() {
	setopt local_options null_glob   # unmatched globs vanish instead of erroring
	local gui_dir="$HOME/Library/Application Support/pritunl/profiles"
	local cli
	cli=$(_pritunl_cli) || return 1
	if [[ ! -d "$gui_dir" ]]; then
		echo "pritunl-sync: GUI profile dir not found: $gui_dir" >&2
		return 1
	fi
	local ovpns=("$gui_dir"/*.ovpn)
	if (( ${#ovpns} == 0 )); then
		echo "pritunl-sync: no GUI profiles (.ovpn) found in $gui_dir" >&2
		return 1
	fi

	# Wipe existing CLI profiles so the CLI ends up mirroring the GUI exactly.
	pritunl-clear

	# Import each GUI profile (needs a matching .conf next to the .ovpn).
	local ovpn base conf work combined tar inner
	for ovpn in $ovpns; do
		base="${ovpn:t:r}"        # filename without dir or .ovpn extension
		conf="$gui_dir/$base.conf"
		if [[ ! -f "$conf" ]]; then
			echo "pritunl-sync: skipping $base (no matching .conf)" >&2
			continue
		fi
		work=$(mktemp -d) || return 1
		combined="$work/$base.ovpn"
		inner=$(sed -e 's/^{//' -e 's/}$//' "$conf")   # conf JSON minus outer braces

		# Tag the display name so CLI copies are distinguishable from the GUI's
		# own profiles. Profiles differ in shape: synced ones have user/server but
		# no "name", while plain-imported ones carry only a "name". Use the existing
		# "name" if present, else derive the app's "<user-before-@> (<server>)", then
		# append " cli". Strip any existing "name" key first so we don't end up with
		# duplicate keys (Go keeps the last, which would drop our tag).
		local existing uname sname pname
		existing=$(grep -o '"name":"[^"]*"' "$conf" | head -1 | sed 's/.*:"//;s/"$//')
		if [[ -n "$existing" ]]; then
			pname="$existing"
		else
			uname=$(grep -o '"user":"[^"]*"' "$conf" | head -1 | sed 's/.*:"//;s/"$//')
			sname=$(grep -o '"server":"[^"]*"' "$conf" | head -1 | sed 's/.*:"//;s/"$//')
			pname="${uname%%@*}"
			[[ -n "$sname" ]] && pname="$pname ($sname)"
		fi
		pname="$pname cli"
		inner=$(printf '%s' "$inner" | sed -e 's/"name":"[^"]*"//' -e 's/^,//' -e 's/,$//' -e 's/,,/,/g')
		if [[ -n "$inner" ]]; then
			inner="\"name\":\"$pname\",$inner"
		else
			inner="\"name\":\"$pname\""
		fi

		printf '#{\n#%s\n#}\n' "$inner" > "$combined"
		cat "$ovpn" >> "$combined"
		tar="$work/$base.tar"
		COPYFILE_DISABLE=1 tar -cf "$tar" -C "$work" "$base.ovpn"
		echo "pritunl-sync: adding $base"
		"$cli" add "$tar"
		rm -rf "$work"
	done

	"$cli" list
}

# Pritunl: interactive VPN selector (fzf) — toggle a single tunnel. Thin wrapper
# over the overlay script that kitty also binds (winmode → v), so the same picker
# is available straight from the shell.
vpn() {
	"$HOME/.config/kitty/vpn.sh"
}
