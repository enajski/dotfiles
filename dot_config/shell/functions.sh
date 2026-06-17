# Shared shell functions for zsh and bash.

mkcd() {
  mkdir -p "$1" && cd "$1"
}

retry() {
  sleep_time=${RETRY_SLEEP:-1}
  while ! "$@"; do
    printf "Command failed, retrying in %ss: %s\n" "$sleep_time" "$*"
    sleep "$sleep_time"
  done
}

extract() {
  if [ $# -ne 1 ]; then
    printf "usage: extract <archive>\n" >&2
    return 2
  fi

  case "$1" in
    *.tar.bz2) tar xjf "$1" ;;
    *.tar.gz) tar xzf "$1" ;;
    *.tar.xz) tar xJf "$1" ;;
    *.bz2) bunzip2 "$1" ;;
    *.gz) gunzip "$1" ;;
    *.tar) tar xf "$1" ;;
    *.tbz2) tar xjf "$1" ;;
    *.tgz) tar xzf "$1" ;;
    *.zip) unzip "$1" ;;
    *) printf "extract: unsupported archive: %s\n" "$1" >&2; return 1 ;;
  esac
}

groot() {
  git rev-parse --show-toplevel 2>/dev/null
}

cdroot() {
  root=$(groot) || return
  cd "$root"
}

