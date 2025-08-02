# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git 1password alias-finder dotenv ssh dnf)

export JAVA8_HOME=/usr/lib/jvm/java-8-openjdk/jre/bin/java

export XDG_DATA_DIRS="$HOME/.local/share:/usr/local/share:/usr/share"

export PATH="/usr/local/sbin:/usr/local/bin:/usr/bin:/usr/bin/site_perl:/usr/bin/vendor_perl:/usr/bin/core_perl:/usr/lib/jvm/java-8-openjdk/jre/bin:/usr/local/go/bin:$HOME/bin:$HOME/.local/bin:/usr/local/bini:/opt/nvim-linux-x86_64/bin"

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='mvim'
fi

# Environment Variables
export NVIM_QT_RUNTIME_PATH=~/.local/nvim-qt.app/src/gui/runtime

# The next line updates PATH for the Google Cloud SDK.
# if [ -f $HOME/google-cloud-sdk/path.zsh.inc ]; then
#   source "$HOME/google-cloud-sdk/path.zsh.inc"
# fi
# 
# # The next line enables shell command completion for gcloud.
# if [ -f $HOME/google-cloud-sdk/completion.zsh.inc ]; then
#   source "$HOME/google-cloud-sdk/completion.zsh.inc"
# fi

# If not running interactively, don"t do anything
[[ $- != *i* ]] && return

# Aliases
alias ls="ls --color=auto"
alias cleanup=cleanup_fedora
alias pbcopy="wl-copy"
alias pbpaste="wl-paste"
alias del="rm -rfv"
alias pkglist="dnf repoquery --userinstalled --qf "%{name}" > $HOME/pkglist.txt && echo \"Backup package list created successfully at $HOME\""
alias dotfiles="/usr/bin/git --git-dir=$HOME/Projects/dotfiles/ --work-tree=$HOME"
alias vim="nvim"
alias proj="cd $HOME/Documents/Projects/"
alias rm="rm -I"

# Environment Variables
# export NVIM_QT_RUNTIME_PATH=~/.local/nvim-qt.app/src/gui/runtime
export TERM=konsole
export EDITOR=nvim

# Fuzzy Find
# [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
# export PYENV_ROOT="$HOME/.pyenv"
# command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
# eval "$(pyenv init -)"

eval "$(pay-respects zsh --alias)"
alias f="$(pay-respects zsh)"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion

function check_for_update() {
   local last_update_file="$HOME/.last_update_check"
   local current_date=$(date +%s)
   if [[ -f $last_update_file ]]; then
        local last_update_date=$(cat $last_update_file)
    else
        local last_update_date=0
    fi

    # Calculate the time difference in seconds (14 days = 1209600 seconds)
    local time_diff=$((current_date - last_update_date))
    local two_weeks_in_seconds=1209600

    # If two weeks have passed, prompt the user for an update
    if [[ $time_diff -ge $two_weeks_in_seconds ]]; then
        echo "It's been two weeks since your last system update."
        echo "Do you want to update now? (Y/n): \c"
        read answer
        if [[ $answer == "" || $answer == "y" || $answer == "Y" ]]; then
            update_fedora
            echo $current_date > $last_update_file
        else
            echo "You chose not to update. I'll remind you again in two weeks."
        fi
    fi
}

check_for_update

function update_fedora() {
    sudo dnf update && sudo dnf upgrade && cleanup
}

function update_arch() {
    sudo pacman -Syu && omz update && cleanup
}

function cleanup_fedora() {
    sudo dnf clean all
}

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

export GPG_TTY=$(tty)
