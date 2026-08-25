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

mangrep() {
    local page
    local search_term="${1:-.}" 
    
    page=$(apropos "$search_term" | fzf --prompt="Man> " \
        --preview="echo {} | awk -F ' - ' '{print \$1}' | awk -F ',' '{print \$1}' | sed -E 's/^([^[:space:](]+)[[:space:]]*\(([^)]+)\).*/\2 \1/' | xargs man" \
        --preview-window=right:60%)

    if [[ -n "$page" ]]; then
        local cmd_args
        cmd_args=$(echo "$page" | awk -F ' - ' '{print $1}' | awk -F ',' '{print $1}' | sed -E 's/^([^[:space:](]+)[[:space:]]*\(([^)]+)\).*/\2 \1/')
        
        # shellcheck disable=SC2086
        man $cmd_args
    fi
}

fman() {
    local page
    local search_term="."
    
    # 1. Base options: Only use 'begin' for tiebreaking in All mode.
    # We remove 'length' here so long descriptions don't ruin the sorting.
    local fzf_opts="--tiebreak=begin"
    local prompt="Man (All)> "

    if [[ "$1" == "-c" ]]; then
        # 2. In command-only mode, we CAN safely use 'length' because --nth=1 
        # forces fzf to ignore the description entirely when calculating length.
        fzf_opts="--tiebreak=begin,length --delimiter= -  --nth=1"
        prompt="Man (Cmd)> "
        shift 
    fi
    
    if [[ -n "$1" ]]; then
        search_term="$1"
    fi
    
    # 3. The Magic Pipeline: 
    # apropos -> awk (calculates length of cmd) -> sort (numerically) -> cut (removes the length number) -> fzf
    page=$(apropos "$search_term" | awk '{print length($1), $0}' | sort -n | cut -d" " -f2- | fzf --prompt="$prompt" $fzf_opts \
        --preview="echo {} | awk -F ' - ' '{print \$1}' | awk -F ',' '{print \$1}' | sed -E 's/^([^[:space:](]+)[[:space:]]*\(([^)]+)\).*/\2 \1/' | xargs man" \
        --preview-window=right:60%)

    if [[ -n "$page" ]]; then
        local cmd_args
        cmd_args=$(echo "$page" | awk -F ' - ' '{print $1}' | awk -F ',' '{print $1}' | sed -E 's/^([^[:space:](]+)[[:space:]]*\(([^)]+)\).*/\2 \1/')
        
        # shellcheck disable=SC2086
        man $cmd_args
    fi
}
