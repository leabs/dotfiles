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
    link_file "$file" "$home/$(basename "$file")"
  done
}

os="$(detect_os)"

if [[ -z "$os" ]]; then
  echo "Unsupported OS. OSTYPE=${OSTYPE:-unknown} uname=$(uname -s 2>/dev/null || true)" >&2
  exit 1
fi

echo "Detected OS: $os"
sync_dir "$script_dir/common"
sync_dir "$script_dir/$os"
if [[ "$os" == "macos" ]]; then
  setup_macos_shell
fi
ensure_local_override "$script_dir/common/.gitconfig.local.example" "$home/.gitconfig.local"
echo "Done."
