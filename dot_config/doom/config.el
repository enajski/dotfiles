;;; config.el -*- lexical-binding: t; -*-

(setq user-full-name (or (getenv "GIT_AUTHOR_NAME") user-full-name)
      user-mail-address (or (getenv "GIT_AUTHOR_EMAIL") user-mail-address))

(setq doom-theme 'doom-one
      display-line-numbers-type t
      org-directory (expand-file-name "~/org/"))

(when (member "JetBrainsMono Nerd Font" (font-family-list))
  (setq doom-font (font-spec :family "JetBrainsMono Nerd Font" :size 14)))

(setq confirm-kill-emacs nil)

(after! org
  (setq org-startup-indented t
        org-hide-emphasis-markers t
        org-return-follows-link t))

(when (file-readable-p (expand-file-name "local.el" doom-user-dir))
  (load! "local"))

