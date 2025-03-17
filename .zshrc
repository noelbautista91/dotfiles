# -----------------------------------------------
# General Settings and oh-my-zsh Configuration
# -----------------------------------------------
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
# Uncomment as needed:
# CASE_SENSITIVE="true"
# HYPHEN_INSENSITIVE="true"

# Auto-update behavior (disabled here)
zstyle ':omz:update' mode disabled
# zstyle ':omz:update' mode auto
# zstyle ':omz:update' mode reminder

# Plugins
plugins=(git)

# Base PATH settings
export PATH="/usr/local/sbin:/usr/local/bin:/usr/bin"
export PATH="/usr/bin/site_perl:/usr/bin/vendor_perl:/usr/bin/core_perl:$(ruby -e print Gem.user_dir)/bin:$PATH"
export PATH="/usr/lib/jvm/java-8-openjdk/jre/bin:/usr/local/go/bin:$PATH"
export XDG_DATA_DIRS="$HOME/.local/share:/usr/local/share:/usr/share"

# Additional environment variables
export JAVA8_HOME=/usr/lib/jvm/java-8-openjdk/jre/bin/java
export TERM=xterm-kitty
export EDITOR=nvim

# Source oh-my-zsh
source $ZSH/oh-my-zsh.sh

# ------------------------------------------------
# OS-Specific Updates
# ------------------------------------------------

function update-system-and-packages() {
  echo "Attempting to update system and packages"
  if [[ "$OSTYPE" == linux-gnu* ]]; then
    echo "OSTYPE == linux-gnu*"
    echo "Loading /etc/os-release"
    source /etc/os-release
    if [[ "$ID_LIKE" == "arch" ]]; then
      echo "Detected Arch Linux"
      echo "Performing `sudo pacman -Syu`"
      sudo pacman -Syu
      echo "Performing `yay -Syu`"
      yay -Syu
      echo "Performing `omz update`"
      omz update
    else
      echo "Unsupported Linux distribution: $ID_LIKE"
    fi
  elif [[ "$OSTYPE" == darwin* ]]; then
    echo "OSTYPE == darwin"
    echo "Downloading software update from Apple"
    sudo /usr/sbin/softwareupdate -ia
    echo "Performing `brew update`"
    brew update
    echo "Performing `brew outdated`"
    brew outdated
    echo "Performing `brew upgrade`"
    brew upgrade
    echo "Performing `brew cleanup`"
    brew cleanup
    echo "Performing `omz update`"
    omz update
  else
    echo "Unsupported OS"
  fi
}

# ------------------------------------------------
# Ask for update every two weeks
# ------------------------------------------------

last_update_file="$HOME/.last_update_check"
current_date=$(date +%s)
last_update_date=0

# Read the last update date if the file exists.
if [[ -f "$last_update_file" ]]; then
  last_update_date=$(< "$last_update_file")
fi

two_weeks_in_seconds=1209600
time_diff=$((current_date - last_update_date))

if (( time_diff >= two_weeks_in_seconds )); then
  printf "It's been two weeks since your last system update.\nDo you want to update now? (Y/n): "
  read -r answer
  # If answer is empty or starts with y or Y, then proceed.
  if [[ -z "$answer" || "$answer" =~ ^[Yy] ]]; then
    update-system-and-packages
    echo "$current_date" > "$last_update_file"
  else
    printf "Update skipped; you'll be reminded again in two weeks.\n"
  fi
else
  echo "Updated within the past 2 weeks, skipping upgrade check"
fi

# -----------------------------------------------
# OS-Specific Aliases
# -----------------------------------------------

if [[ "$OSTYPE" == linux-gnu* ]]; then
  echo "Setting Linux-specific aliases"

  alias ls="ls --color=auto"
  alias pbcopy="xsel --clipboard --input"
  alias pbpaste="xsel --clipboard --output"
elif [[ "$OSTYPE" == darwin* ]]; then
  echo "Setting MacOS-specific aliases"

  export PATH="/opt/homebrew/bin:$PATH"
  alias openapp="open"
fi

# -----------------------------------------------
# Common Aliases & Environment Variables
# -----------------------------------------------
echo "Setting common aliases"

alias v="nvim"
alias vim="nvim"
alias vs="nvim ."
alias sauce="source ./env/bin/activate"
alias proj="cd ~/Documents/Projects"
alias del="rm -rfv"
alias dotfiles="/usr/bin/git --git-dir=$HOME/Projects/dotfiles/ --work-tree=$HOME"
alias rm="rm -I"

# Setup fzf if installed
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Python environment setup via pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"

# Node Version Manager (nvm) setup
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"

# Google Cloud SDK (if installed)
if [ -f "$HOME/google-cloud-sdk/path.zsh.inc" ]; then
  source "$HOME/google-cloud-sdk/path.zsh.inc"
fi
if [ -f "$HOME/google-cloud-sdk/completion.zsh.inc" ]; then
  source "$HOME/google-cloud-sdk/completion.zsh.inc"
fi

# Exit early if not running interactively
[[ $- != *i* ]] && return

# Additional environment variables
export NVIM_QT_RUNTIME_PATH="$HOME/.local/nvim-qt.app/src/gui/runtime"

