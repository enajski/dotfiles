# Shared interactive shell behavior for zsh and bash.

if [ -r "$HOME/.config/shell/aliases.sh" ]; then
  . "$HOME/.config/shell/aliases.sh"
fi

if [ -r "$HOME/.config/shell/functions.sh" ]; then
  . "$HOME/.config/shell/functions.sh"
fi

if command -v starship >/dev/null 2>&1; then
  if [ -n "${ZSH_VERSION:-}" ]; then
    eval "$(starship init zsh)"
  elif [ -n "${BASH_VERSION:-}" ]; then
    eval "$(starship init bash)"
  fi
fi

if command -v direnv >/dev/null 2>&1; then
  if [ -n "${ZSH_VERSION:-}" ]; then
    eval "$(direnv hook zsh)"
  elif [ -n "${BASH_VERSION:-}" ]; then
    eval "$(direnv hook bash)"
  fi
fi

if command -v zoxide >/dev/null 2>&1; then
  if [ -n "${ZSH_VERSION:-}" ]; then
    eval "$(zoxide init zsh)"
  elif [ -n "${BASH_VERSION:-}" ]; then
    eval "$(zoxide init bash)"
  fi
fi

if [ -r "$HOME/.config/shell/local.aliases" ]; then
  . "$HOME/.config/shell/local.aliases"
fi

