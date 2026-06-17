# Shared environment for zsh and bash.

path_prepend() {
  case ":$PATH:" in
    *":$1:"*) ;;
    *) PATH="$1${PATH:+:$PATH}" ;;
  esac
}

path_append() {
  case ":$PATH:" in
    *":$1:"*) ;;
    *) PATH="${PATH:+$PATH:}$1" ;;
  esac
}

path_prepend "$HOME/.local/bin"
path_prepend "$HOME/bin"
path_prepend "$HOME/.emacs.d/bin"

if [ -d /opt/homebrew/bin ]; then
  path_prepend /opt/homebrew/bin
  path_prepend /opt/homebrew/sbin
fi

if [ -d /usr/local/bin ]; then
  path_prepend /usr/local/bin
fi

export PATH
export EDITOR="${EDITOR:-vim}"
export VISUAL="${VISUAL:-vim}"
export PAGER="${PAGER:-less}"
export LESS="${LESS:--FRX}"

if [ -r "$HOME/.config/shell/local.env" ]; then
  . "$HOME/.config/shell/local.env"
fi
