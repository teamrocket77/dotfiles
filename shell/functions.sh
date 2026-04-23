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

# used to source dir
# source_dir(){
#     for file in "$1"/*; do
#       if [[ -f "$file" ]]; then
#         source "$file"
#       fi
#     done
# }

