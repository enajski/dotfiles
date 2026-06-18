;;; config.el -*- lexical-binding: t; -*-

;; Identity
(setq user-full-name "Wojtek")

;; Visuals and defaults (ported from Spacemacs)
(setq doom-theme 'solarized-light
      doom-font (font-spec :family "Fira Code" :size 15)
      doom-symbol-font (font-spec :family "Symbols Nerd Font Mono" :size 13)
      display-line-numbers-type t
      fill-column 120
      which-key-side-window-location 'bottom)

;; TAB should indent/align, never insert literal tab chars by default.
(setq-default indent-tabs-mode nil
              tab-always-indent t)

;; Re-assert after startup in case upstream packages reset defaults.
(defun my/enforce-space-indentation ()
  (setq-default indent-tabs-mode nil)
  (setq indent-tabs-mode nil))

(add-hook 'after-init-hook #'my/enforce-space-indentation)
(add-hook 'after-change-major-mode-hook #'my/enforce-space-indentation)
(add-hook 'prog-mode-hook #'my/enforce-space-indentation)
(add-hook 'text-mode-hook #'my/enforce-space-indentation)
(add-hook 'emacs-startup-hook
          (lambda ()
            (run-at-time 0.1 nil #'my/enforce-space-indentation)))

;; Keep default register behavior stable; clipboard is bridged explicitly in -nw below.
(setq evil-want-clipboard nil)

(after! nerd-icons
  (setq nerd-icons-font-family "Symbols Nerd Font Mono"))

(when (display-graphic-p)
  (let ((symbols-font (or (find-font (font-spec :family "Symbols Nerd Font Mono"))
                          (find-font (font-spec :family "Symbols Nerd Font")))))
    (when symbols-font
      (set-fontset-font t 'unicode symbols-font nil 'prepend))))

;; In terminal Emacs (-nw), Nerd Font glyph coverage is terminal-font-dependent.
;; Use ASCII/plain fallbacks there to avoid missing-icon placeholders.
(unless (display-graphic-p)
  (setq doom-modeline-icon nil
        doom-modeline-major-mode-icon nil
        doom-modeline-minor-modes nil
        doom-modeline-unicode-fallback t
        treemacs-no-png-images t
        nerd-icons-font-family nil))

;; Clipboard integration.
(setq select-enable-clipboard t
      select-enable-primary t
      ;; Avoid synchronous clipboard polling on every kill/yank in terminal Emacs.
      save-interprogram-paste-before-kill nil)

(defvar my/system-clipboard-last-text nil)

(defun my/macos-clipboard-set (text &optional _push)
  "Copy TEXT to the macOS pasteboard."
  (when (stringp text)
    (setq my/system-clipboard-last-text text)
    (with-temp-buffer
      (insert text)
      (call-process-region (point-min) (point-max) "pbcopy" nil 0))))

(defun my/macos-clipboard-get ()
  "Return text from the macOS pasteboard, or nil if Emacs set it last."
  (let ((text (with-temp-buffer
                (call-process "pbpaste" nil t nil)
                (buffer-string))))
    (unless (or (string-empty-p text)
                (string= text my/system-clipboard-last-text))
      text)))

(defun my/wsl-clipboard-set (text &optional _push)
  "Copy TEXT to the Windows clipboard from WSL."
  (when (stringp text)
    (setq my/system-clipboard-last-text text)
    (with-temp-buffer
      (insert text)
      (call-process-region (point-min) (point-max) "clip.exe" nil 0))))

(defun my/wsl-clipboard-get ()
  "Return text from the Windows clipboard, or nil if Emacs set it last."
  (let ((text (string-trim-right
               (replace-regexp-in-string
                "\r" ""
                (with-temp-buffer
                  (call-process "powershell.exe" nil t nil
                                "-NoProfile" "-Command" "Get-Clipboard -Raw")
                  (buffer-string))))))
    (unless (or (string-empty-p text)
                (string= text my/system-clipboard-last-text))
      text)))

(unless (display-graphic-p)
  ;; Clear inherited terminal providers to avoid mixed/partial writes.
  (setq interprogram-cut-function nil
        interprogram-paste-function nil)
  (cond
   ((and (eq system-type 'darwin)
         (executable-find "pbcopy")
         (executable-find "pbpaste"))
    (fset 'gui-select-text #'my/macos-clipboard-set)
    (fset 'gui-selection-value #'my/macos-clipboard-get)
    (setq interprogram-cut-function #'my/macos-clipboard-set
          interprogram-paste-function #'my/macos-clipboard-get))
   ((and (executable-find "clip.exe") (executable-find "powershell.exe"))
    (fset 'gui-select-text #'my/wsl-clipboard-set)
    (fset 'gui-selection-value #'my/wsl-clipboard-get)
    (setq interprogram-cut-function #'my/wsl-clipboard-set
          interprogram-paste-function #'my/wsl-clipboard-get))))

(after! treemacs
  (unless (display-graphic-p)
    (setq treemacs-no-png-images t)
    (when (fboundp 'treemacs-load-theme)
      (treemacs-load-theme "Default"))))

;; Tone down Magit hunk/line highlight intensity vs Solarized Light
(after! magit
  (custom-set-faces!
    ;; Less saturated hunk heading and focused hunk heading
    '(magit-diff-hunk-heading :background "#eee8d5" :foreground "#657b83")
    '(magit-diff-hunk-heading-highlight :background "#e8e2cc" :foreground "#586e75")
    ;; Subtle line highlight overlays
    '(magit-diff-context-highlight :background "#f7f3e8" :foreground "#657b83")
    '(magit-diff-added-highlight :background "#edf4e8" :foreground "#586e75")
    '(magit-diff-removed-highlight :background "#f7ece8" :foreground "#586e75")))

;; Leader/localleader parity
(setq doom-leader-key "SPC"
      doom-localleader-key ",")

;; Spacemacs muscle memory: `SPC SPC` opens M-x
(map! :leader
      "SPC" #'execute-extended-command
      "TAB" #'evil-switch-to-windows-last-buffer
      "v"   #'er/expand-region
      "f t" #'+treemacs/toggle
      ";" nil
      (:prefix (";" . "comment")
       ";" #'comment-line))

(defun my/select-window-by-number (n)
  "Select window N by left-to-right order. N=0 selects the 10th window."
  (interactive "p")
  (let* ((windows (window-list (selected-frame) 'no-minibuffer (frame-first-window)))
         (index (if (zerop n) 9 (1- n))))
    (if (< index (length windows))
        (select-window (nth index windows))
      (user-error "No window %d" n))))

(map! :leader
      "0" (cmd! (my/select-window-by-number 0))
      "1" (cmd! (my/select-window-by-number 1))
      "2" (cmd! (my/select-window-by-number 2))
      "3" (cmd! (my/select-window-by-number 3))
      "4" (cmd! (my/select-window-by-number 4))
      "5" (cmd! (my/select-window-by-number 5))
      "6" (cmd! (my/select-window-by-number 6))
      "7" (cmd! (my/select-window-by-number 7))
      "8" (cmd! (my/select-window-by-number 8))
      "9" (cmd! (my/select-window-by-number 9)))

;; Keep M-m available in emacs/insert state (Spacemacs emacs leader muscle memory)
(map! :i "M-m" #'doom/leader
      :e "M-m" #'doom/leader)

;; In insert/emacs states, TAB aligns/indents line at point.
(map! :i [tab] #'indent-for-tab-command
      :e [tab] #'indent-for-tab-command)

;; Always move point on left-click (GUI + terminal + evil states)
(setq mouse-autoselect-window t)

(global-set-key [mouse-1] #'mouse-set-point)

(after! evil
  ;; Keep pasted text register stable when replacing visual selections.
  (setq evil-kill-on-visual-paste nil)
  (dolist (map (list evil-normal-state-map
                     evil-motion-state-map
                     evil-insert-state-map
                     evil-emacs-state-map
                     evil-visual-state-map))
    (define-key map [mouse-1] #'mouse-set-point)))

(unless (display-graphic-p)
  (xterm-mouse-mode 1))

;; LSP behavior parity
(after! lsp-mode
  (setq lsp-headerline-breadcrumb-enable nil
        lsp-idle-delay 1.0
        lsp-ui-sideline-show-code-actions nil
        lsp-ui-doc-show-with-mouse nil
        lsp-log-io nil
        lsp-disabled-clients '(semgrep-ls))
  (dolist (path '("[/\\\\]\\.clj-kondo\\'"
                  "[/\\\\]\\.cp-cache\\'"
                  "[/\\\\]\\.cpcache\\'"
                  "[/\\\\]\\.lsp\\'"
                  "[/\\\\]\\.shadow-cljs\\'"
                  "[/\\\\]\\.resources\\'"
                  "[/\\\\]\\.target\\'"
                  "[/\\\\]\\.git\\'"))
    (add-to-list 'lsp-file-watch-ignored-directories path)))

;; Clojure keybinding parity for your custom smartparens workflow
(map! :map (clojure-mode-map
            clojurescript-mode-map
            clojurec-mode-map)
      :localleader
      "(" #'sp-wrap-round
      "[" #'sp-wrap-square
      "{" #'sp-wrap-curly
      "," #'sp-forward-slurp-sexp
      "." #'sp-forward-barf-sexp)

;; Keep CIDER + LSP together, with preferred indentation/cider behavior
(after! cider
  (setq cider-repl-pop-to-buffer-on-connect nil)
  (defun my/clojure-goto-definition-dwim ()
    "Use CIDER definition when connected, else fall back to LSP/xref definition."
    (interactive)
    (cond
     ((and (fboundp 'cider-connected-p)
           (cider-connected-p)
           (fboundp 'cider-find-var))
      (call-interactively #'cider-find-var))
     ((and (fboundp 'lsp-mode)
           (bound-and-true-p lsp-mode)
           (fboundp 'lsp-find-definition))
      (call-interactively #'lsp-find-definition))
     ((fboundp 'xref-find-definitions)
      (call-interactively #'xref-find-definitions))
     (t
      (user-error "No CIDER connection and no LSP/xref definition backend available"))))
  ;; Spacemacs muscle memory: , e p e => pprint eval last sexp in popup buffer
  (map! :map (clojure-mode-map clojurescript-mode-map clojurec-mode-map cider-mode-map)
        :localleader
        (:prefix ("g" . "goto")
         "g" #'my/clojure-goto-definition-dwim)
        (:prefix ("e" . "eval")
         (:prefix ("p" . "print")
          "e" #'cider-pprint-eval-last-sexp))))

(add-hook 'clojure-mode-hook
          (lambda ()
            (setq-local copilot-indent-offset 2)))

(use-package! codetutor
  :demand t
  :init
  (setq codetutor-backend 'auto
        codetutor-model nil
        codetutor-open-on-enable nil
        codetutor-start-session-on-open t
        codetutor-review-on-save t)
  :config
  (dolist (mode '(clojure-mode
                  clojurescript-mode
                  clojurec-mode
                  clojure-ts-mode
                  clojurescript-ts-mode
                  clojurec-ts-mode))
    (add-to-list 'codetutor-language-by-major-mode
                 (cons mode 'clojure)))
  (defun my/codetutor-decode-utf-8 (text)
    "Decode byte-encoded UTF-8 backend output before CodeTutor renders it."
    (cond
     ((not (stringp text)) text)
     ((not (multibyte-string-p text))
      (decode-coding-string text 'utf-8 t))
     ((string-match-p "[\200-\377]" text)
      (decode-coding-string (string-make-unibyte text) 'utf-8 t))
     (t text)))
  (advice-add 'codetutor--backend-answer :filter-return
              #'my/codetutor-decode-utf-8)
  (codetutor-mode 1))

;; Keep your shell environment import behavior for GUI sessions
(when (display-graphic-p)
  (when (require 'exec-path-from-shell nil t)
    (exec-path-from-shell-initialize)
    (exec-path-from-shell-copy-env "NODE_EXTRA_CA_CERTS")))

;; Utility function parity
(defun escape-double-quotes (start end)
  "Escape double quotes in the selected region."
  (interactive "r")
  (save-excursion
    (goto-char start)
    (while (re-search-forward "\"" end t)
      (replace-match "\\\\\"" nil t))))

(map! "C-c e" #'escape-double-quotes)

;; Markdown export/preview parity
(setq markdown-command "pandoc -f markdown -t html --standalone"
      markdown-command-needs-filename nil)

(defun my/markdown-preview-eww ()
  "Export current markdown buffer to HTML and preview it in eww."
  (interactive)
  (unless (derived-mode-p 'markdown-mode)
    (user-error "Not a markdown buffer"))
  (let* ((src-buf (current-buffer))
         (src-text (with-current-buffer src-buf (buffer-string)))
         (html-file (expand-file-name
                     (format "md-preview-%s.html"
                             (if-let ((f (buffer-file-name src-buf)))
                                 (md5 f)
                               (md5 (buffer-name src-buf))))
                     temporary-file-directory)))
    (with-temp-buffer
      (insert src-text)
      (let ((exit-code
             (call-process-region
              (point-min) (point-max)
              shell-file-name
              nil (list (current-buffer) nil) nil
              shell-command-switch
              (format "%s > %s"
                      markdown-command
                      (shell-quote-argument html-file)))))
        (unless (and (integerp exit-code) (zerop exit-code))
          (user-error "Markdown export failed (exit %s). Output:\n%s"
                      exit-code
                      (buffer-string)))))
    (eww-open-file html-file)))

(map! :map markdown-mode-map
      :localleader
      "p" #'my/markdown-preview-eww)

;; Spacemacs-like localleader editing helper
(defun my/split-line-and-indent ()
  "Split at point, move to new line, and indent/alignment.
The cursor ends up at the split site on the new line."
  (interactive)
  (let ((col (current-column))
        (orig-line-beg (line-beginning-position))
        (orig-line-end (line-end-position)))
    (split-line)
    (forward-line 1)
    (move-to-column col t)
    (indent-according-to-mode)
    ;; Ensure split operation never leaves trailing whitespace artifacts.
    (save-excursion
      (delete-trailing-whitespace orig-line-beg orig-line-end)
      (delete-trailing-whitespace (line-beginning-position) (line-end-position)))))

;; Always trim trailing whitespace on save.
(defun my/delete-trailing-whitespace-before-save ()
  "Delete trailing whitespace before saving the current buffer."
  (delete-trailing-whitespace))

(add-hook 'before-save-hook #'my/delete-trailing-whitespace-before-save)

(map! :localleader
      (:prefix ("s" . "split")
       "l" #'my/split-line-and-indent))

;; Whitespace-based paragraph navigation on { and }
(defun my/goto-prev-blank-line-block ()
  "Move to the first blank separator line after previous paragraph."
  (interactive)
  (beginning-of-line)
  ;; If we're inside text, first get to the separator after this paragraph.
  (unless (looking-at-p "^[ \t]*$")
    (while (and (not (eobp)) (not (looking-at-p "^[ \t]*$")))
      (forward-line 1)))
  ;; Move backward to previous paragraph's separator.
  (while (and (not (bobp)) (looking-at-p "^[ \t]*$"))
    (forward-line -1))
  (while (and (not (bobp)) (not (looking-at-p "^[ \t]*$")))
    (forward-line -1))
  ;; Ensure we land on the separator (blank) line itself.
  (unless (looking-at-p "^[ \t]*$")
    (goto-char (point-min))))

(defun my/goto-next-blank-line-block ()
  "Move to the first blank separator line after current/next paragraph."
  (interactive)
  (beginning-of-line)
  ;; If currently on a separator, jump to next paragraph first.
  (when (looking-at-p "^[ \t]*$")
    (while (and (not (eobp)) (looking-at-p "^[ \t]*$"))
      (forward-line 1)))
  ;; Move to the first blank separator after the paragraph.
  (while (and (not (eobp)) (not (looking-at-p "^[ \t]*$")))
    (forward-line 1))
  (when (eobp)
    (goto-char (point-max))
    (beginning-of-line)))

(map! :n "{" #'my/goto-prev-blank-line-block
      :n "}" #'my/goto-next-blank-line-block
      :m "{" #'my/goto-prev-blank-line-block
      :m "}" #'my/goto-next-blank-line-block)

;; Treemacs width should be mouse-resizable by default
(after! company
  ;; Spacemacs parity: complete relative/absolute file paths inside strings.
  (set-company-backend! 'prog-mode
    '(company-capf :with company-files)
    'company-yasnippet)
  (set-company-backend! 'conf-mode
    '(company-capf :with company-files)
    'company-dabbrev-code
    'company-yasnippet))

(after! treemacs
  (setq treemacs-width-is-initially-locked nil)
  (add-hook 'treemacs-mode-hook
            (lambda ()
              (setq-local window-size-fixed nil))))

;; Machine-local overrides, e.g. backend/model choices and private tokens.
(load! "local" nil t)
