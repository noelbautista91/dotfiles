#!/bin/bash
create_symlinks() {
  local source_dir="$1"
  local target_dir="$2"

  # Ensure target directory exists
  mkdir -p "$target_dir"

  for item in "$source_dir"/*; do
    # Skip if item does not exist (handles empty directories)
    [ -e "$item" ] || continue

    local basename=$(basename "$item")
    local target_item="$target_dir"

    ln -snf "$item" "$target_item"
    if [ -d "$item" ]; then
      echo "Created symbolic link for directory $basename"
    else
      echo "Created symbolic link for file $basename"
    fi
  done
}

echo "Creating symbolic link to .zshrc"
rm -f $HOME/.zshrc && ln -snf $(realpath ./.zshrc) $HOME/.zshrc && echo ".zshrc is now available"

echo "Reload ~/.zshrc with 'source ~/.zshrc'"

echo "Creating symbolic link to .gitconfig"
ln -snf "$(realpath ./.gitconfig)" "$HOME/.gitconfig"

echo "Creating symbolic link to .tmux.conf"
ln -snf "$(realpath ./.tmux.conf)" "$HOME/.tmux.conf"

echo "Creating symbolic links to app configs in ~/.config/"
CONFIG_TARGET_DIR="$HOME/.config"
CONFIG_SOURCE_DIR="$(realpath ./.config)"

# Check if the current directory has a .config directory
if [ ! -d "$CONFIG_SOURCE_DIR" ]; then
  echo "No .config directory found in the current directory."
fi

create_symlinks "$CONFIG_SOURCE_DIR" "$CONFIG_TARGET_DIR"

echo "Creating symbolic links for Oh My Zsh custom themes"
OMZ_THEMES_SOURCE_DIR="$(realpath ./.oh-my-zsh/custom/themes)"
OMZ_THEMES_TARGET_DIR="$HOME/.oh-my-zsh/custom/themes"

if [ ! -d "$HOME/.oh-my-zsh" ]; then
  echo "Oh My Zsh is not installed at ~/.oh-my-zsh. Skipping theme symlinks."
elif [ ! -d "$OMZ_THEMES_SOURCE_DIR" ]; then
  echo "No custom themes found in dotfiles repository. Skipping."
else
  mkdir -p "$OMZ_THEMES_TARGET_DIR"
  for theme_file in "$OMZ_THEMES_SOURCE_DIR"/*.zsh-theme; do
    [ -e "$theme_file" ] || continue
    theme_basename=$(basename "$theme_file")
    ln -snf "$theme_file" "$OMZ_THEMES_TARGET_DIR/$theme_basename"
    echo "Created symbolic link for Oh My Zsh theme: $theme_basename"
  done
fi

