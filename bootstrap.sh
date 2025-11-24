#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
home="${HOME}"

ensure_local_override() {
  local example="$1"
  local dest="$2"

  if [[ -e "$dest" ]]; then
    return
  fi

  if [[ -f "$example" ]]; then
    cp "$example" "$dest"
    echo "Created $(basename "$dest") from $(basename "$example"). Update it with your info."
  fi
}

install_oh_my_zsh() {
  local ohmyzsh="$home/.oh-my-zsh"

  if [[ -f "$ohmyzsh/oh-my-zsh.sh" ]]; then
    echo "Oh My Zsh already installed."
    return
  fi

  if ! command -v curl >/dev/null 2>&1; then
    echo "Skipping Oh My Zsh install (curl not found)." >&2
    return
  fi

  local installer
  installer="$(mktemp)"

  if curl -fsSL "https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh" -o "$installer"; then
    if RUNZSH=no KEEP_ZSHRC=yes sh "$installer"; then
      echo "Installed Oh My Zsh."
    else
      echo "Warning: Oh My Zsh installer failed." >&2
    fi
  else
    echo "Warning: Could not download Oh My Zsh installer." >&2
  fi

  rm -f "$installer"
}

install_zsh_addon() {
  local repo="$1"
  local dest="$2"
  local label="$3"

  if [[ -d "$dest" ]]; then
    echo "$label already installed."
    return
  fi

  if ! command -v git >/dev/null 2>&1; then
    echo "Skipping $label install (git not found)." >&2
    return
  fi

  mkdir -p "$(dirname "$dest")"
  if git clone --depth 1 "$repo" "$dest"; then
    echo "Installed $label."
  else
    echo "Warning: Failed to install $label." >&2
  fi
}

setup_macos_shell() {
  echo "Ensuring Oh My Zsh, theme, and plugins..."
  install_oh_my_zsh
  local custom="${ZSH_CUSTOM:-$home/.oh-my-zsh/custom}"
  install_zsh_addon "https://github.com/romkatv/powerlevel10k.git" \
    "$custom/themes/powerlevel10k" "Powerlevel10k theme"
  install_zsh_addon "https://github.com/zsh-users/zsh-autosuggestions.git" \
    "$custom/plugins/zsh-autosuggestions" "zsh-autosuggestions plugin"
  install_zsh_addon "https://github.com/zsh-users/zsh-syntax-highlighting.git" \
    "$custom/plugins/zsh-syntax-highlighting" "zsh-syntax-highlighting plugin"
}

configure_macos_zsh_dark_mode() {
  local zsh_local="$home/.zshrc.local"
  local setting='export DOTFILES_TERM_THEME=dark'

  if [[ -f "$zsh_local" ]]; then
    if grep -q '^export DOTFILES_TERM_THEME=dark$' "$zsh_local"; then
      echo "macOS Zsh dark mode preference already set."
      return
    fi

    if grep -q '^export DOTFILES_TERM_THEME=' "$zsh_local"; then
      local tmp
      tmp="$(mktemp)"
      if awk -v setting="$setting" '
        BEGIN { replaced=0 }
        {
          if ($0 ~ /^export DOTFILES_TERM_THEME=/) {
            if (!replaced) { print setting; replaced=1 }
          } else {
            print
          }
        }
        END {
          if (!replaced) { print setting }
        }
      ' "$zsh_local" > "$tmp"; then
        mv "$tmp" "$zsh_local"
        echo "Updated DOTFILES_TERM_THEME to dark in $(basename "$zsh_local")."
      else
        echo "Warning: Could not update $zsh_local for dark mode." >&2
        rm -f "$tmp"
      fi
      return
    fi
  fi

  printf '%s\n' "$setting" >> "$zsh_local"
  echo "Set DOTFILES_TERM_THEME=dark in $(basename "$zsh_local")."
}

ensure_linux_bash_config() {
  local source="$script_dir/linux/.bashrc"
  local shim="$home/.bashrc.dotfiles"
  local bashrc="$home/.bashrc"

  link_file "$source" "$shim"

  if [[ -L "$bashrc" && "$(readlink "$bashrc")" == "$source" ]]; then
    # Replace old one-shot symlink with a file that can keep user content.
    rm "$bashrc"
  fi

  local block
  read -r -d '' block <<'EOF' || true
# >>> dotfiles linux bashrc >>>
if [[ -f "$HOME/.bashrc.dotfiles" ]]; then
  # shellcheck source=/dev/null
  source "$HOME/.bashrc.dotfiles"
fi
# <<< dotfiles linux bashrc <<<
EOF

  if [[ ! -e "$bashrc" ]]; then
    printf '%s\n' "$block" > "$bashrc"
    return
  fi

  if ! grep -Fq 'dotfiles linux bashrc' "$bashrc"; then
    printf '\n%s\n' "$block" >> "$bashrc"
  fi
}

ensure_macos_zsh_config() {
  local source="$script_dir/macos/.zshrc"
  local shim="$home/.zshrc.dotfiles"
  local zshrc="$home/.zshrc"

  link_file "$source" "$shim"

  if [[ -L "$zshrc" && "$(readlink "$zshrc")" == "$source" ]]; then
    # Replace old one-shot symlink with a file that can keep user content.
    rm "$zshrc"
  fi

  local block
  read -r -d '' block <<'EOF' || true
# >>> dotfiles macOS zshrc >>>
if [[ -f "$HOME/.zshrc.dotfiles" ]]; then
  source "$HOME/.zshrc.dotfiles"
fi
# <<< dotfiles macOS zshrc <<<
EOF

  if [[ ! -e "$zshrc" ]]; then
    printf '%s\n' "$block" > "$zshrc"
    return
  fi

  if ! grep -Fq 'dotfiles macOS zshrc' "$zshrc"; then
    printf '\n%s\n' "$block" >> "$zshrc"
  fi
}

require_shell_backup_confirmation() {
  cat <<'EOF'
WARNING: This bootstrap links dotfiles and may update your shell startup files.
Please back up your existing configs (~/.zshrc, ~/.bashrc, ~/.bash_profile, etc.) first.
Press Y to continue after you have backed them up (Ctrl+C to abort).
EOF

  read -r -p "Have you backed up your shell configs? Type Y to proceed: " reply
  if [[ ! "$reply" =~ ^[Yy]$ ]]; then
    echo "Aborting. Back up your shell config first." >&2
    exit 1
  fi
}

detect_os() {
  if [[ -n "${OSTYPE:-}" ]]; then
    case "${OSTYPE}" in
      darwin*) echo "macos"; return ;;
      linux*) echo "linux"; return ;;
      msys*|cygwin*|mingw*) echo "windows"; return ;;
    esac
  fi

  case "$(uname -s 2>/dev/null || true)" in
    Darwin) echo "macos" ;;
    Linux) echo "linux" ;;
    MINGW*|MSYS*|CYGWIN*) echo "windows" ;;
    *) echo "" ;;
  esac
}

link_file() {
  local source="$1"
  local dest="$2"

  mkdir -p "$(dirname "$dest")"
  ln -sfn "$source" "$dest"
  echo "Linked $(basename "$source") -> $dest"
}

sync_dir() {
  local dir="$1"

  [ -d "$dir" ] || return
  find "$dir" -maxdepth 1 -type f -print0 | while IFS= read -r -d '' file; do
    local base
    base="$(basename "$file")"
    if [[ "$base" == ".zshrc" || "$base" == ".bashrc" ]]; then
      # Handle macOS Zsh config separately so we don't clobber user settings.
      continue
    fi
    link_file "$file" "$home/$(basename "$file")"
  done
}

os="$(detect_os)"

if [[ -z "$os" ]]; then
  echo "Unsupported OS. OSTYPE=${OSTYPE:-unknown} uname=$(uname -s 2>/dev/null || true)" >&2
  exit 1
fi

echo "Detected OS: $os"
require_shell_backup_confirmation
sync_dir "$script_dir/common"
sync_dir "$script_dir/$os"
if [[ "$os" == "macos" ]]; then
  setup_macos_shell
  ensure_macos_zsh_config
  configure_macos_zsh_dark_mode
elif [[ "$os" == "linux" ]]; then
  ensure_linux_bash_config
fi
ensure_local_override "$script_dir/common/.gitconfig.local.example" "$home/.gitconfig.local"
echo "Done."
