#!/bin/bash

echo "Installing op password shortcut for keyring - pw"
rm -f $HOME/.local/bin/pw && ln -s $(realpath ./bin/pw) $HOME/.local/bin/pw && echo "pw is now available"

# echo "Pointing .zshenv to $(cat $(realpath ../.zshrc))"
# rm -f $HOME/.zshenv && touch $HOME/.zshenv && echo "export ZDOTDIR=$(realpath ../.zshrc)" >>$HOME/.zshenv

echo "Creating symbolic link to .zshrc"
rm -f $HOME/.zshrc && ln -s $(realpath ./.zshrc) $HOME/.zshrc && echo ".zshrc is now available"

echo "Reload ~/.zshrc with 'source ~/.zshrc'"

if [ ! -d "$HOME/.config/nvim" ]; then
  git clone https://github.com/LazyVim/starter "$HOME/.config/nvim"
  rm -rf "$HOME/.config/nvim/.git"
else
  echo "$HOME/.config/nvim already exists."
fi

echo "Creating symbolic links to app configs in ~/.config/"
CONFIG_TARGET_DIR="$HOME/.config"
CONFIG_SOURCE_DIR="$(realpath ./.config)"

# Check if the current directory has a .config directory
if [ ! -d "$CONFIG_SOURCE_DIR" ]; then
  echo "No .config directory found in the current directory."
fi

# Loop through all files and directories in the .config directory
for item in "$CONFIG_SOURCE_DIR"/*; do
  # Get the basename of the item (file or directory)
  basename=$(basename "$item")

  # Create symbolic link in the $HOME/.config directory
  ln -sf "$item" "$CONFIG_TARGET_DIR/$basename"
  echo "Created symlink for $basename"
done

echo "Symbolic links for ~/.config created."
