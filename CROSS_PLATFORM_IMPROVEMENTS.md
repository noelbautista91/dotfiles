# Cross-Platform Dotfiles Improvements

## Issues Found

### .zshrc
1. **Line 73**: `dnf` plugin is Fedora-specific (not available on macOS)
2. **Line 79**: Hard-coded Linux paths (`/usr/lib/jvm/`, `nvim-linux-x86_64`, `/usr/local/go`)
3. **Line 103**: `ls --color=auto` (Linux) vs `ls -G` (macOS)
4. **Line 105-106**: `wl-copy`/`wl-paste` are Wayland-specific (Linux), macOS already has `pbcopy`/`pbpaste`
5. **Line 108**: `pkglist` alias uses `dnf` (Fedora-only)
6. **Line 119**: `TERM=konsole` is KDE-specific
7. **Line 166-176**: Update functions only for Fedora/Arch, missing macOS
8. **Line 196**: Hard-coded `/home/noelbautista91` path

### .gitconfig
1. **Line 10**: 1Password SSH sign path (`/opt/1Password/op-ssh-sign` on Linux vs `/Applications/1Password.app/Contents/MacOS/op-ssh-sign` on macOS)
2. **Line 20**: `osxkeychain` is macOS-only - Linux needs different credential helper (libsecret or none)

### bin/pw
1. **Lines 15, 20**: Uses `xclip` (Linux-only) - should use `pbcopy`/`pbpaste` on macOS

### install.sh
- No OS detection or conditional logic
- Installs all configs regardless of platform compatibility

---

## Recommended Changes

### 1. .zshrc - Add OS Detection

Add at the beginning (after ZSH config):
```bash
# Detect OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
fi
```

### 2. .zshrc - Conditional Plugin Loading

Replace line 73:
```bash
# Load OS-specific plugins
if [[ "$OS" == "linux" ]]; then
    plugins=(git 1password dotenv ssh dnf)
else
    plugins=(git 1password dotenv ssh brew)
fi
```

### 3. .zshrc - OS-Specific PATH

Replace line 79 with conditional paths:
```bash
if [[ "$OS" == "macos" ]]; then
    export PATH="$HOME/bin:$HOME/.local/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
    # Homebrew
    if [[ -d "/opt/homebrew/bin" ]]; then
        export PATH="/opt/homebrew/bin:$PATH"
    fi
    # Add Go if installed via Homebrew
    if [[ -d "/opt/homebrew/opt/go/bin" ]]; then
        export PATH="/opt/homebrew/opt/go/bin:$PATH"
    fi
else
    export PATH="/usr/local/sbin:/usr/local/bin:/usr/bin:/usr/bin/site_perl:/usr/bin/vendor_perl:/usr/bin/core_perl:/usr/lib/jvm/java-8-openjdk/jre/bin:/usr/local/go/bin:$HOME/go/bin:$HOME/bin:$HOME/.local/bin:$HOME/.local/bin/nvim-linux-x86_64/bin:/usr/local/bin"
fi

# Common paths
export PATH="$HOME/go/bin:$PATH"
```

### 4. .zshrc - Conditional Aliases

Replace lines 103-108:
```bash
# OS-specific aliases
if [[ "$OS" == "macos" ]]; then
    alias ls="ls -G"
    # pbcopy/pbpaste already exist on macOS
    alias pkglist="brew list --formula > $HOME/pkglist.txt && echo 'Backup package list created successfully at $HOME'"
else
    alias ls="ls --color=auto"
    alias pbcopy="wl-copy"
    alias pbpaste="wl-paste"
    alias pkglist="dnf repoquery --userinstalled --qf '%{name}\n' > $HOME/pkglist.txt && echo 'Backup package list created successfully at $HOME'"
fi

# Common aliases
alias cleanup=cleanup_system
alias del="rm -rfv"
# ... rest of common aliases
```

### 5. .zshrc - Conditional TERM

Replace line 119:
```bash
if [[ "$OS" == "linux" ]]; then
    export TERM=konsole
fi
```

### 6. .zshrc - Cross-Platform Update Functions

Replace lines 166-176:
```bash
function update_system() {
    if [[ "$OS" == "macos" ]]; then
        update_macos
    elif [[ -f /etc/fedora-release ]]; then
        update_fedora
    elif [[ -f /etc/arch-release ]]; then
        update_arch
    else
        echo "Unknown Linux distribution"
    fi
}

function update_macos() {
    echo "Updating Homebrew..."
    brew update && brew upgrade && brew cleanup
    echo "Updating Oh My Zsh..."
    omz update
}

function update_fedora() {
    sudo dnf update && sudo dnf upgrade && cleanup_system
}

function update_arch() {
    sudo pacman -Syu && omz update && cleanup_system
}

function cleanup_system() {
    if [[ "$OS" == "macos" ]]; then
        brew cleanup
    elif [[ -f /etc/fedora-release ]]; then
        cleanup_fedora
    fi
}

function cleanup_fedora() {
    sudo dnf clean all
}
```

### 7. .zshrc - Fix PNPM Path

Replace line 196:
```bash
export PNPM_HOME="$HOME/.local/share/pnpm"
```

### 8. .zshrc - Conditional SUDO_EDITOR

Replace line 100:
```bash
if [[ "$OS" == "linux" ]]; then
    export SUDO_EDITOR=$HOME/.local/bin/nvim-linux-x86_64/bin/nvim
fi
```

---

### 9. .gitconfig - Split into Base + OS-Specific

Create `.gitconfig.linux`:
```ini
[gpg "ssh"]
	program = /opt/1Password/op-ssh-sign

[credential]
	helper = cache --timeout=3600
```

Create `.gitconfig.macos`:
```ini
[gpg "ssh"]
	program = /Applications/1Password.app/Contents/MacOS/op-ssh-sign

[credential]
	helper = osxkeychain
```

Update `.gitconfig` to remove lines 9-10 and 19-20, add at the end:
```ini
[includeIf "gitdir:~/"]
	path = ~/.gitconfig.linux

[includeIf "gitdir:~/"]
	path = ~/.gitconfig.macos
```

**Better approach**: Use conditional includes based on OS detection script, or simpler - just use one include that checks if file exists:
```ini
[include]
	path = ~/.gitconfig.local
```

Then create `.gitconfig.local` on each machine with OS-specific settings.

---

### 10. bin/pw - Cross-Platform Clipboard

Replace entire file:
```bash
#!/bin/bash

# Detect OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    CLIPBOARD_COPY="pbcopy"
    CLIPBOARD_PASTE="pbpaste"
else
    # Linux - prefer wl-copy (Wayland) over xclip (X11)
    if command -v wl-copy &> /dev/null; then
        CLIPBOARD_COPY="wl-copy"
        CLIPBOARD_PASTE="wl-paste"
    else
        CLIPBOARD_COPY="xclip -selection clipboard"
        CLIPBOARD_PASTE="xclip -o -selection clipboard"
    fi
fi

# Try to get the password and store both stdout and stderr into the variable
password_output=$(op item get orbiter --format json --fields password 2>&1)

# Check if the result contains an error by searching for the string '[ERROR]'
if echo "$password_output" | grep -q "\[ERROR\]"; then
	echo "Error occurred: $password_output"
	exit 1 # Exit the script if there's an error
fi

# Extract the actual password
password=$(echo "$password_output" | jq -r .value)

# Copy the password to clipboard
echo -n "$password" | $CLIPBOARD_COPY

# Clear the clipboard after 60 seconds, but only if it still contains the password
(
	sleep 60
	if [[ "$($CLIPBOARD_PASTE)" == "$password" ]]; then
		# If the clipboard still contains the password, clear it
		echo -n "" | $CLIPBOARD_COPY
	fi
) &
```

---

### 11. install.sh - Add OS Detection

Add at the beginning:
```bash
#!/bin/bash

# Detect OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
    echo "Detected macOS"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
    echo "Detected Linux"
else
    echo "Unknown OS: $OSTYPE"
    exit 1
fi
```

Add conditional logic before creating symlinks:
```bash
# Validate required tools exist
if [[ "$OS" == "macos" ]]; then
    if ! command -v brew &> /dev/null; then
        echo "Warning: Homebrew not found. Install from https://brew.sh"
    fi
else
    # Linux checks
    if ! command -v dnf &> /dev/null && [[ -f /etc/fedora-release ]]; then
        echo "Warning: dnf not found but Fedora detected"
    fi
fi

# Install OS-specific git config
if [[ "$OS" == "macos" ]]; then
    echo "Setting up macOS-specific git config..."
    git config --global gpg.ssh.program "/Applications/1Password.app/Contents/MacOS/op-ssh-sign"
    git config --global credential.helper osxkeychain
else
    echo "Setting up Linux-specific git config..."
    git config --global gpg.ssh.program "/opt/1Password/op-ssh-sign"
    git config --global credential.helper "cache --timeout=3600"
fi
```

---

## Implementation Priority

1. **High Priority**: .zshrc OS detection and PATH (breaks on wrong OS)
2. **High Priority**: bin/pw clipboard compatibility (script fails on wrong OS)
3. **Medium Priority**: .gitconfig split (1Password signing won't work)
4. **Medium Priority**: Conditional aliases and functions
5. **Low Priority**: install.sh improvements (nice to have validation)

## Testing Plan

1. Test on Fedora: Source .zshrc, run update functions, test clipboard
2. Test on macOS: Source .zshrc, run update functions, test clipboard
3. Verify git signing works on both platforms
4. Run install.sh on both platforms
