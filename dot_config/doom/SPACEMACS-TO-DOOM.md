# Spacemacs → Doom Emacs (Your Setup)

This migration is already applied on your machine.

## What was changed

- Your active `~/.emacs.d` was replaced with Doom Emacs.
- Your previous active Spacemacs directory was preserved as:
  - `~/.emacs.d.spacemacs-active-20260312`
- Your earlier backup remains intact:
  - `~/.emacs.d.20260312`
- New Doom private config was created at:
  - `~/.config/doom/init.el`
  - `~/.config/doom/config.el`
  - `~/.config/doom/packages.el`

## Spacemacs behavior mirrored

### Core key workflow

- Leader key: `SPC`
- Emacs-state leader muscle memory: `M-m` mapped to Doom leader
- Major-mode leader/localleader: `,`
- `SPC SPC` mapped to `M-x`

### Clojure/CIDER workflow parity

Custom Clojure smartparens bindings preserved on localleader:

- `, (` → `sp-wrap-round`
- `, [` → `sp-wrap-square`
- `, {` → `sp-wrap-curly`
- `, ,` → `sp-forward-slurp-sexp`
- `, .` → `sp-forward-barf-sexp`

Other parity choices:

- `cider-repl-pop-to-buffer-on-connect` set to `nil`
- `copilot-indent-offset` set to `2` in `clojure-mode`

### LSP behavior parity

Copied from your Spacemacs preferences:

- Breadcrumbs off
- Idle delay `1.0`
- LSP UI sideline code actions off
- LSP doc-on-mouse off
- `semgrep-ls` disabled
- File-watch ignore list includes:
  - `.clj-kondo`, `.cp-cache`, `.cpcache`, `.lsp`, `.shadow-cljs`, `.resources`, `.target`, `.git`

### Markdown utility parity

Preserved your markdown preview function:

- `my/markdown-preview-eww`
- `, p` in markdown mode triggers preview
- `markdown-command` uses pandoc HTML standalone export

### Extra custom utility parity

- `C-c e` bound to `escape-double-quotes`

### Visual parity choices

- Theme: `solarized-light`
- Font: `Fira Code` size `13`
- Line numbers enabled
- Fill column `120`
- `which-key` bottom positioning retained

## Doom modules enabled to match your prior usage

- Completion: `helm`
- UI: `doom`, `dashboard`, `modeline`, `workspaces`, `(treemacs +lsp)`
- Editor: `(evil +everywhere)`, `fold`, `multiple-cursors`, `snippets`
- Tools: `(lsp +peek)`, `magit`, `lookup`, `(eval +overlay)`
- Lang: `(clojure +lsp)`, `(java +lsp)`, `(javascript +lsp)`, `markdown`, `data`, `yaml`, `plantuml`, `sh`, `emacs-lisp`

Additional packages installed for parity:

- `solarized-theme`
- `exec-path-from-shell`
- `copilot`

## Spacemacs → Doom key mental map

- Spacemacs “layers” → Doom “modules” (`doom!` in `init.el`)
- Spacemacs `dotspacemacs/user-config` → Doom `config.el`
- Spacemacs additional packages list → Doom `packages.el` + `doom sync`
- Spacemacs `SPC m` major-mode map → Doom localleader (`,`)

## Daily commands (Doom equivalents)

- Sync after changing `init.el` or `packages.el`:
  - `~/.emacs.d/bin/doom sync`
- Diagnose setup:
  - `~/.emacs.d/bin/doom doctor`
- Update Doom/packages:
  - `~/.emacs.d/bin/doom upgrade`

## Current warnings from doctor (non-blocking)

These do not prevent Doom from working, but you may want to fix them:

- `Symbola` font missing
- `fd` binary missing (slower file searches)
- JS/TSX warning unless `+tree-sitter` is enabled
- `plantuml.jar` missing
- `shellcheck` missing

Because sudo requires a password in this environment, system package installation
was not performed automatically.

## If you want to switch back temporarily

1. Move Doom aside:
   - `mv ~/.emacs.d ~/.emacs.d.doom`
2. Restore your previous active Spacemacs dir:
   - `mv ~/.emacs.d.spacemacs-active-20260312 ~/.emacs.d`
