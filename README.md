# Portable dotfiles

Personal dotfiles managed with [chezmoi](https://www.chezmoi.io/).

This repo is the source state. `chezmoi apply` renders it into `$HOME`,
including shell entry points and Doom Emacs private config.

## Scope

- Doom Emacs private config in `~/.config/doom`
- zsh and bash entry points
- shared shell aliases, environment, path, and helpers
- local/private machine overrides that are deliberately not tracked

## Why this shape

This repo uses chezmoi to manage configuration files so that different
machines can have different configurations without maintaining multiple
repositories.

## Layout

```text
dot_config/
  doom/                 -> ~/.config/doom
  shell/                -> ~/.config/shell
dot_zshrc.tmpl          -> ~/.zshrc
dot_bashrc.tmpl         -> ~/.bashrc
dot_bash_profile.tmpl   -> ~/.bash_profile
scripts/bootstrap.sh    local installer/apply helper
```

`*.tmpl` files are rendered by chezmoi. Non-template shell files are plain
POSIX-ish shell so both zsh and bash can source them.

## Bootstrap

From a fresh checkout:

```sh
./scripts/bootstrap.sh
```

If no chezmoi config exists yet, the script writes
`~/.config/chezmoi/chezmoi.toml` with this checkout as `sourceDir`. If a config
already exists, the script leaves it untouched and applies this repo with an
explicit `--source` argument.

Then inspect changes before applying future updates:

```sh
chezmoi diff
chezmoi apply
```

On an existing machine, import current files before applying over them:

```sh
chezmoi add ~/.zshrc ~/.bashrc ~/.bash_profile ~/.config/doom
chezmoi diff
```

## Local overrides

These files are sourced when present and should not be committed:

- `~/.config/shell/local.env`
- `~/.config/shell/local.aliases`
- `~/.config/shell/local.zsh`
- `~/.config/shell/local.bash`
- `~/.config/doom/local.el`

Put machine-specific paths, work credentials, API tokens, and experimental
one-off settings there. If a setting is useful on more than one machine, move
it into the tracked files and gate it with a chezmoi template condition.

## Doom Emacs

Doom expects the private config to contain `init.el`, `config.el`, and
`packages.el`. After changing modules or packages:

```sh
doom sync
```

After applying this repo to a new machine, make sure Doom itself and its
runtime dependencies are installed separately. At minimum Doom needs Git,
Emacs, ripgrep, and GNU find; `fd` is optional but useful.

## Shell conventions

- `.zshrc` and `.bashrc` only source shared files.
- Shared exports live in `~/.config/shell/env.sh`.
- Interactive behavior lives in `~/.config/shell/interactive.sh`.
- Aliases live in `~/.config/shell/aliases.sh`.
- Functions live in `~/.config/shell/functions.sh`.
- Private/local overrides are sourced last.
