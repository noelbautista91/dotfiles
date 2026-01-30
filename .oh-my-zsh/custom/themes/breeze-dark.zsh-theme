# Breeze Dark Theme for Oh My Zsh
# Based on robbyrussell theme with KDE Breeze Dark colors
# See .config/colors/breeze-dark.conf for full palette reference

# Breeze Dark color definitions using ANSI 256-color codes
local breeze_blue='%F{39}'       # #3DAEE9 - Primary accent (ANSI cyan)
local breeze_green='%F{35}'      # #27AE60 - Success (ANSI green)
local breeze_red='%F{167}'       # #DA4453 - Error (ANSI red)
local breeze_yellow='%F{221}'    # #FDBC4B - Warning/Git info (ANSI yellow)
local breeze_orange='%F{208}'    # #F67400 - Git dirty marker (ANSI orange)
local breeze_gray='%F{145}'      # #A1A9B1 - Secondary text (ANSI gray)
local reset='%f'

# Primary prompt with robbyrussell-style arrow
# Success: green arrow, Error: red arrow
PROMPT='%(?.%F{35}.%F{167})➜%f %F{221}%~%f $(git_prompt_info)'

# Git prompt settings
ZSH_THEME_GIT_PROMPT_PREFIX="%F{145}git:(%f%F{221}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%f"
ZSH_THEME_GIT_PROMPT_DIRTY="%F{145})%f %F{208}✗%f"
ZSH_THEME_GIT_PROMPT_CLEAN="%F{145})%f"
