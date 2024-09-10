#!/bin/bash

cat <<-ENDRC > ~/.bashrc
	#
	# ~/.bashrc
 	#
		
	# If not running interactively, don't do anything
 	[[ $- != *i* ]] && return	
	alias ls='ls --color=auto'
	alias grep='grep --color=auto'
	alias yay='paru -Syupw && paru -c && paru -S --needed'
	alias yeet='paru -R'
	PS1='[\[\e[38;5;51;1;2m\]\u\[\e[0;1m\]@\[\e[38;5;51;2m\]\h\[\e[0m\]\w]\$ '
	ENDRC
