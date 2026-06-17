#!/usr/bin/env sh
set -eu

repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
config_home=${XDG_CONFIG_HOME:-"$HOME/.config"}
chezmoi_config_dir="$config_home/chezmoi"
chezmoi_config="$chezmoi_config_dir/chezmoi.toml"

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

if [ ! -e "$chezmoi_config" ] &&
  [ ! -e "$chezmoi_config_dir/chezmoi.yaml" ] &&
  [ ! -e "$chezmoi_config_dir/chezmoi.yml" ] &&
  [ ! -e "$chezmoi_config_dir/chezmoi.json" ] &&
  [ ! -e "$chezmoi_config_dir/chezmoi.jsonc" ]; then
  mkdir -p "$chezmoi_config_dir"
  printf 'sourceDir = "%s"\n' "$repo_dir" > "$chezmoi_config"
else
  cat <<EOF
Found an existing chezmoi config under:
  $chezmoi_config_dir

Leaving it unchanged. This script will still apply this checkout explicitly.
If plain 'chezmoi diff' or 'chezmoi apply' should use this repo, set:
  sourceDir = "$repo_dir"

EOF
fi

chezmoi --source "$repo_dir" apply

cat <<'EOF'

Dotfiles applied.

Useful next commands:
  chezmoi diff
  chezmoi status
  chezmoi apply
EOF
