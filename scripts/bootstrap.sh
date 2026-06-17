#!/usr/bin/env sh
set -eu

repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
config_home=${XDG_CONFIG_HOME:-"$HOME/.config"}
chezmoi_config_dir="$config_home/chezmoi"
chezmoi_config="$chezmoi_config_dir/chezmoi.toml"
os_name=$(uname -s)

install_apt_packages() {
  apt_packages=

  if ! command -v chezmoi >/dev/null 2>&1; then
    apt_packages="$apt_packages chezmoi"
  fi

  if ! command -v zsh >/dev/null 2>&1; then
    apt_packages="$apt_packages zsh"
  fi

  if ! command -v git >/dev/null 2>&1; then
    apt_packages="$apt_packages git"
  fi

  if ! command -v curl >/dev/null 2>&1 && ! command -v wget >/dev/null 2>&1; then
    apt_packages="$apt_packages curl"
  fi

  if [ -n "$apt_packages" ]; then
    if ! command -v sudo >/dev/null 2>&1; then
      cat >&2 <<EOF
Missing packages:$apt_packages

Install them with apt, then rerun:
  apt-get update
  apt-get install -y$apt_packages
EOF
      exit 1
    fi

    sudo apt-get update
    sudo apt-get install -y $apt_packages
  fi
}

download_zimfw() {
  zim_home=${ZIM_HOME:-"${ZDOTDIR:-"$HOME"}/.zim"}
  zimfw_path="$zim_home/zimfw.zsh"

  if [ -r "$zimfw_path" ]; then
    return 0
  fi

  if command -v curl >/dev/null 2>&1; then
    curl -fsSL --create-dirs -o "$zimfw_path" \
      https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
  elif command -v wget >/dev/null 2>&1; then
    mkdir -p "$zim_home"
    wget -nv -O "$zimfw_path" \
      https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
  else
    cat >&2 <<'EOF'
zimfw needs either curl or wget to install.

On Ubuntu:
  sudo apt install curl
EOF
    exit 1
  fi
}

if [ "$os_name" = Linux ] && command -v apt-get >/dev/null 2>&1; then
  install_apt_packages
fi

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

if [ "$os_name" = Darwin ] && command -v brew >/dev/null 2>&1; then
  if ! brew list --formula zimfw >/dev/null 2>&1; then
    brew install zimfw
  fi
elif [ "$os_name" = Linux ]; then
  if command -v brew >/dev/null 2>&1; then
    if ! brew list --formula zimfw >/dev/null 2>&1; then
      brew install zimfw
    fi
  else
    download_zimfw
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
