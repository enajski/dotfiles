;; -*- no-byte-compile: t; -*-
;;; $DOOMDIR/packages.el

;; Spacemacs parity additions
(package! solarized-theme)
(package! exec-path-from-shell)
(package! copilot)
(package! codetutor
  :recipe (:host github :repo "jaketothepast/codetutor"))

;; Prevent warm alternate background effects from loading at all.
(package! solaire-mode :disable t)
