alias g="git"
alias ...="cd .."
alias gitnoe='git commit --amend --no-edit'
alias lsd='ls -d */'
alias ll='ls -al'
alias tnew='tmux new-session -s init'
if [ $+command[docker] ]; then
	alias dcb='docker compose down && docker compose build'
	alias dcu='docker compose up'
fi
if [ $+command[gls] ]; then
	alias lsh='gls --ignore="*zip"'
fi

if [ $+command[terraform] ]; then
	alias tf="terraform"
	alias tfp="tf plan"
	alias tfa="tf apply"
	alias tfv='terraform validate'
	tfaa(){
		terraform $1 --auto-approve
	}
fi
