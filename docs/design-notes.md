# Dotfiles design notes

Useful patterns:

- Keep application configs under `config/` and materialize them under
  `~/.config/`.
- Split platform-specific shell entry points into platform folders.
- Keep setup automation grouped so a new machine can be bootstrapped in stages.
- Put larger workstation provisioning in Ansible rather than cramming every
  package install into shell startup.

Tradeoffs to avoid copying directly:

- Handwritten symlinks work, but they become brittle once hosts differ.
- Installer scripts should not be the only source of truth for file placement.
- Private/local overrides need a clear convention from day one.

## Tool choice

`chezmoi` is the default for this repo because it provides:

- source-state management with `chezmoi diff`, `chezmoi apply`, and
  `chezmoi update`;
- templates based on OS, host, architecture, and custom data;
- a clean path for secrets/password-manager integration later;
- a single repo layout that can still render different files on different
  machines.

Alternatives considered:

- GNU Stow: excellent if every machine should receive the same symlink tree.
  It is intentionally simple and package-oriented, but host-specific rendering
  has to be bolted on separately.
- yadm: strong Git-native dotfiles manager with alternates and encryption. It
  is a good option when you want `$HOME` itself to behave like the repository.
  This repo favors an explicit source-state model instead.

## Current scope

- `~/.config/doom`
- `~/.zshrc`
- `~/.bashrc`
- `~/.bash_profile`
- shared shell files under `~/.config/shell`

## Sources

- chezmoi daily workflow: https://www.chezmoi.io/user-guide/daily-operations/
- chezmoi templating: https://www.chezmoi.io/user-guide/templating/
- Doom Emacs getting started: https://github.com/doomemacs/doomemacs/blob/master/docs/getting_started.org

