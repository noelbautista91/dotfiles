#
# ~/.bashrc
#

# If not running interactively, don"t do anything
[[ $- != *i* ]] && return

PS1="[ \u@\h \W]\ $ "

# Aliases
alias ls="ls --color=auto"
alias cleanup="sudo pacman -Sc; paccache -ruk0; sudo pacman -Rns $(pacman -Qtdq)"
alias rm="rm -I"
