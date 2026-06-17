#!/usr/bin/env sh
set -eu

repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)

if ! command -v chezmoi >/dev/null 2>&1; then
  if command -v brew >/dev/null 2>&1; then
    brew install chezmoi
  else
    cat >&2 <<'EOF'
chezmoi is not installed.

Install it with your package manager, then rerun:
  ./scripts/bootstrap.sh

Examples:
  brew install chezmoi
  sudo apt install chezmoi
  sudo dnf install chezmoi
EOF
    exit 1
  fi
fi

chezmoi init --source "$repo_dir"
chezmoi apply

cat <<'EOF'

Dotfiles applied.

Useful next commands:
  chezmoi diff
  chezmoi status
  chezmoi apply
EOF

