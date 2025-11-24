# P10k instant prompt (must stay at very top)
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Base env vars
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
export EDITOR="${EDITOR:-code --wait}"

# Local overrides and secrets
[[ -f "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"

# Homebrew
if command -v brew >/dev/null 2>&1; then
  eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv)" 2>/dev/null
fi

# Docker
source "$HOME/.docker/init-zsh.sh" 2>/dev/null || true

# iTerm2
test -e "$HOME/.iterm2_shell_integration.zsh" && source "$HOME/.iterm2_shell_integration.zsh" 2>/dev/null

# GNU Make
export PATH="$(brew --prefix)/opt/make/libexec/gnubin:$PATH" 2>/dev/null

# Bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
[[ -s "$HOME/.bun/_bun" ]] && source "$HOME/.bun/_bun" 2>/dev/null

# Flutter
export PATH="$HOME/GitHub/flutter/bin:$PATH"

# NVM (Node)
export NVM_DIR="$HOME/.nvm"
[[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh" --no-use 2>/dev/null
nvm use 18 >/dev/null 2>&1 || nvm use system >/dev/null 2>&1

# Ruby and RVM
export PATH="$HOME/.gem/bin:$HOME/.rvm/bin:$PATH"

# Oh-My-Zsh load (only if installed; skip missing-plugin noise)
export ZSH="$HOME/.oh-my-zsh"
export ZSH_DISABLE_COMPFIX="true"
if [[ -d "$ZSH/custom/themes/powerlevel10k" ]]; then
  ZSH_THEME="powerlevel10k/powerlevel10k"
else
  ZSH_THEME="robbyrussell"
fi
plugins=(git)
[[ -d "$ZSH/custom/plugins/zsh-autosuggestions" ]] && plugins+=(zsh-autosuggestions)
[[ -d "$ZSH/custom/plugins/zsh-syntax-highlighting" ]] && plugins+=(zsh-syntax-highlighting)
[[ -f "$ZSH/oh-my-zsh.sh" ]] && source "$ZSH/oh-my-zsh.sh"

# Aliases
alias python='python3'
alias ll='ls -lah'
alias gs='git status -sb'
alias gl='git log --oneline --graph --decorate -20'
alias ytmp4='yt-dlp -f best --recode-video mp4 -o "%(title)s.%(ext)s"'

# P10k config
[[ -f ~/.p10k.zsh ]] && source ~/.p10k.zsh
