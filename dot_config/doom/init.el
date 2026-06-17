;;; init.el -*- lexical-binding: t; -*-

;; Current canonical stack keeps Helm for Spacemacs-style workflow parity.
;; Explore replacing Helm with Vertico later if you want lighter, more native
;; minibuffer completion (`vertico` + `consult` + `orderless` + `marginalia`).
(doom! :input
       :completion
       company
       helm

       :ui
       doom
       dashboard
       hl-todo
       modeline
       ophints
       (popup +defaults)
       (vc-gutter +pretty)
       vi-tilde-fringe
       workspaces
       (window-select +numbers)
       (treemacs +lsp)

       :editor
       (evil +everywhere)
       file-templates
       fold
       multiple-cursors
       snippets

       :emacs
       dired
       electric
       tramp
       undo
       vc

       :checkers
       syntax

       :tools
       (eval +overlay)
       lookup
       (lsp +peek)
       magit

       :lang
       (clojure +lsp)
       (java +lsp)
       (javascript +lsp)
       emacs-lisp
       markdown
       data
       plantuml
       sh
       yaml

       :config
       (default +bindings +smartparens))
