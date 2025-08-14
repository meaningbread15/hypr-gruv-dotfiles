# =========================
#   Zsh Configuration
# =========================

# This is my custom zsh-config, feel free to edit it as much as you'd like to.
# Don't forget to edit the timezone.
# There are also some friendly alias to account for the typos that I usually end up doing, could be useful for you too.

# Default text editor
export EDITOR=nvim

# Homebrew setup (Linuxbrew & macOS)
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
export PATH="$PATH:$HOME/.local/bin"

# macOS Homebrew (only runs if brew exists at this path)
if [[ -f "/opt/homebrew/bin/brew" ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# =========================
#   History Configuration
# =========================
HISTFILE=~/.zsh_history   # History file path
HISTSIZE=5000             # Number of lines kept in memory
SAVEHIST=5000             # Number of lines saved to file
setopt share_history hist_ignore_dups hist_ignore_space hist_reduce_blanks

# =========================
#   Fuzzy Finder & Zoxide
# =========================
eval "$(fzf --zsh)"         # Fuzzy finder
eval "$(zoxide init zsh)"  # Smarter cd replacement

# =========================
#   Keybindings
# =========================
bindkey -e                          # Emacs keybindings
bindkey '^r' history-incremental-search-backward
bindkey '^P' up-history
bindkey '^N' down-history

# =========================
#   Autocompletion
# =========================
autoload -Uz compinit
compinit

# =========================
#   Prompt (Gruvbox Theme)
# =========================
local fg="#d5c4a1"
local yellow="#fabd2f"
local aqua="#8ec07c"
local orange="#fe8019"
PROMPT='%B%F{'"$fg"'}%n%b%f@%F{'"$yellow"'}%m%f %F{'"$aqua"'}%~%f %F{'"$orange"'}❯%f '

# =========================
#   Aliases
# =========================

# Safer 'ls' with colors
alias ls='ls --color=auto'
alias la='ls -la --color=auto'

# Misc
alias c='clear'
alias cd..='cd ..'
alias dc..='cd ..'

# Time sync & timezone
alias syncz='sudo timedatectl set-timezone <Your_Timezone>'
alias synct='sudo timedatectl set-ntp true'

# nvim variations
alias nvbi='nvim'
alias nbim='nvim'
alias nvi='nvim'

# Custom scripts (ensure they contain no personal info)
alias batfetch="$HOME/.local/bin/batgreet.sh"

# Run virt-manager via Python (needed on some distros)
alias virt-manager='/usr/bin/python /usr/bin/virt-manager'

# CLI clock
alias clit='tty-clock -c'

# =========================
#   Functions
# =========================

# Create missing directories when opening files in nvim
nvim() {
  local target="$1"
  mkdir -p "$(dirname "$target")"
  command nvim "$@"
}

# Create missing directories when touching files
touch() {
  local target="$1"
  mkdir -p "$(dirname "$target")" && command touch "$target"
}

# =========================
#   Plugins
# =========================
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

# =========================
#   Additional PATH entries
# =========================
export PATH="$PATH:$HOME/.spicetify"


