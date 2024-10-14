#!/bin/zsh
if command -v pyenv ; then
	 pyenv virtualenv 3.11.8 pynvim
	$(pyenv root)/versions/pynvim/bin/pip install pynvim
	echo "$output"
fi
#if command -v rbenv ; then
#	 pyenv virtualenv 3.11.8 pynvim
#	$(pyenv root)/versions/pynvim/bin/pip install pynvim
#	echo "$output"
#fi
