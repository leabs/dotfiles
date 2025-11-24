#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
home="${HOME}"

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
echo "Done."
