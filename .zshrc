export ZSH=$HOME/.oh-my-zsh

ZSH_THEME="dieter"

plugins=(git)

export JAVA8_HOME=/usr/lib/jvm/java-8-openjdk/jre/bin/java

export PATH="/usr/local/sbin:/usr/local/bin:/usr/bin:/usr/bin/site_perl:/usr/bin/vendor_perl:/usr/bin/core_perl:$(ruby -e print Gem.user_dir)/bin:/usr/lib/jvm/java-8-openjdk/jre/bin"

source $ZSH/oh-my-zsh.sh

export LANG=en_US.UTF-8

export ANDROID_HOME=/opt/android-sdk

export SUDO_EDITOR=vim

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
 export EDITOR="vim"
else
  export EDITOR="vim"
fi

# Base16 Shell
BASE16_SHELL="$HOME/.config/base16-shell/base16-default.dark.sh"
  [[ -s $BASE16_SHELL ]] && source $BASE16_SHELL

# Autostart X at login, for Arch Linux
[[ -z $DISPLAY && $XDG_VTNR -eq 1 ]] && exec startx

# Use Python 2 for Google Cloud
export CLOUDSDK_PYTHON="/usr/bin/python2"

# The next line updates PATH for the Google Cloud SDK.
if [ -f $HOME/google-cloud-sdk/path.zsh.inc ]; then
  source "$HOME/google-cloud-sdk/path.zsh.inc"
fi

# The next line enables shell command completion for gcloud.
if [ -f $HOME/google-cloud-sdk/completion.zsh.inc ]; then
  source "$HOME/google-cloud-sdk/completion.zsh.inc"
fi

# If not running interactively, don"t do anything
[[ $- != *i* ]] && return

# Aliases
alias ls="ls --color=auto"
alias cleanup="sudo pacman -Sc; paccache -ruk0; sudo pacman -Rns $(pacman -Qtdq)"
alias pbcopy="xsel --clipboard --input"
alias pbpaste="xsel --clipboard --output"
alias del="rm -rfv"
alias pkglist="pacman -Qqe >> $HOME/pkglist.txt && echo \"Backup package list created successfully at $HOME\""
alias dotfiles="/usr/bin/git --git-dir=$HOME/Projects/dotfiles/ --work-tree=$HOME"
