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
