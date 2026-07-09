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

if [ -r "$HOME/.sdkman/bin/sdkman-init.sh" ]; then
  . "$HOME/.sdkman/bin/sdkman-init.sh"
fi

# Point sdkman JDKs at the system Java trust store so update-ca-certificates
# (corporate CAs, etc.) is honoured. Run after `sdk install java <ver>`.
# ponytail: manual re-run per new JDK; wrap `sdk` if that gets annoying.
sdk_link_cacerts() {
  system_cacerts=/etc/ssl/certs/java/cacerts
  [ -r "$system_cacerts" ] || { echo "no $system_cacerts (install ca-certificates-java)" >&2; return 1; }
  for d in "$HOME"/.sdkman/candidates/java/*/lib/security; do
    [ -d "$d" ] || continue
    ln -sfn "$system_cacerts" "$d/cacerts"
  done
}

if [ -r "/snap/bin" ]; then
  path_prepend /snap/bin
fi

if [ -d "$HOME/go/bin" ]; then
  path_prepend "$HOME/go/bin"
fi

export PATH
export EDITOR="${EDITOR:-vim}"
export VISUAL="${VISUAL:-vim}"
export PAGER="${PAGER:-less}"
export LESS="${LESS:--FRX}"

if [ -r "$HOME/.config/shell/local.env" ]; then
  . "$HOME/.config/shell/local.env"
fi
