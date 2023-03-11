;;; init --- ...
;;; Commentary:
;;; Code:
(setq inhibit-message t)
(add-hook
 'after-init-hook ;;
 #'(lambda () (setq inhibit-message nil)))
(require 'cl-lib)
(require 'use-package)
(setq use-package-always-defer nil)
(setq use-package-always-demand t)
(setq use-package-always-ensure nil)
(use-package better-defaults)
(scroll-bar-mode +1)
(defalias 'yes-or-no-p 'y-or-n-p)
(setq frame-title-format
      '((:eval
         (if-let ((n (buffer-file-name)))
           (file-relative-name n (getenv "HOME"))
           (concat (buffer-name) " in " default-directory)))
        vc-mode))
(setq-default visible-bell t)
(setq ring-bell-function 'ignore)
(setq-default mode-line-format nil)
(setq-default inhibit-startup-screen t)
(setq-default kill-buffer-query-functions nil)
(setq-default kill-emacs-query-functions nil)
(setq auto-revert-verbose nil)
(global-so-long-mode +1)
(global-auto-revert-mode +1)
(global-visual-line-mode -1)
(global-eldoc-mode +1)
(global-reveal-mode +1)
(toggle-truncate-lines +1)
(visual-line-mode -1)
(use-package
 evil
 :init (setq evil-want-keybinding nil)
 :config
 (define-key evil-normal-state-map (kbd "C-z") 'evil-normal-state)
 (define-key evil-emacs-state-map (kbd "C-z") 'evil-emacs-state)
 (define-key evil-insert-state-map (kbd "C-z") 'evil-normal-state)
 (define-key minibuffer-local-map [escape] #'minibuffer-keyboard-quit)
 (define-key
  minibuffer-local-ns-map [escape] #'minibuffer-keyboard-quit)
 (define-key
  minibuffer-local-completion-map [escape] #'minibuffer-keyboard-quit)
 (define-key
  minibuffer-local-must-match-map [escape] #'minibuffer-keyboard-quit)
 (define-key
  minibuffer-local-isearch-map [escape] #'minibuffer-keyboard-quit)
 (add-function
  :after (symbol-function 'recenter-top-bottom) #'evil-show-file-info)
 (setq
  evil-insert-state-cursor '("#952111" (bar . 3)) ;;
  evil-normal-state-cursor '("#33A050" (hbar . 4)) ;;
  evil-operator-state-cursor '(box) ;;
  evil-emacs-state-cursor '(bar) ;;
  evil-motion-state-cursor '(bar) ;;
  evil-visual-state-cursor '("#11312F" hbar . hollow))
 (cl-loop
  for
  state
  in
  '(insert normal)
  do
  (evil-global-set-key state (kbd "C-a") 'beginning-of-line)
  (evil-global-set-key state (kbd "C-h") 'delete-backward-char)
  (evil-global-set-key state (kbd "C-e") 'end-of-line)
  (evil-global-set-key state (kbd "C-k") 'kill-line)))
(evil-mode +1)
(use-package
 evil-collection
 :after evil
 :config
 (setq evil-want-integration t)
 (evil-collection-init))
(use-package
 evil-goggles
 :after (evil)
 :custom (evil-goggles-duration 0.9)
 :config (evil-goggles-mode +1)
 (custom-set-faces
  '(evil-goggles-delete-face ((t (:inherit magit-diff-removed))))
  '(evil-goggles-yank-face ((t (:inherit magit-diff-base-highlight))))
  '(evil-goggles-paste-face ((t (:inherit magit-diff-added))))
  '(evil-goggles-commentary-face
    ((t (:inherit magit-diff-context-highlight))))
  '(evil-goggles-indent-face
    ((t (:inherit magit-diff-added-highlight))))))
(use-package
 evil-commentary
 :after (evil)
 :config (evil-commentary-mode +1))
(use-package
 avy
 :after (evil)
 :config
 (global-set-key (kbd "M-t") 'avy-goto-word-1)
 (setq avy-style 'words)
 (evil-global-set-key 'normal (kbd "g h") 'avy-goto-char)
 (evil-global-set-key 'normal (kbd "g b") 'avy-goto-word-1)
 (evil-global-set-key 'normal (kbd "g t") 'avy-goto-line)
 (evil-global-set-key 'normal (kbd "g :") 'avy-goto-line))
(use-package
 evil-snipe
 :after evil
 :config
 (evil-snipe-mode +1)
 (evil-snipe-override-mode +1))
(use-package
 evil-exchange
 :after (evil)
 :commands (evil-exchange evil-exchange-cancel)
 :config
 (define-key evil-normal-state-map "gx" #'evil-exchange)
 (define-key evil-visual-state-map "gx" #'evil-exchange)
 (define-key evil-normal-state-map "gX" #'evil-exchange-cancel)
 (define-key evil-visual-state-map "gX" #'evil-exchange-cancel))
(use-package editorconfig :config (editorconfig-mode +1))
(use-package
 pdf-tools
 :hook (after-init . pdf-tools-install)
 :config
 (add-hook 'pdf-view-mode-hook (lambda () (blink-cursor-mode -1))))
(use-package
 feebleline
 :custom
 (feebleline-show-git-branch t)
 (feebleline-show-dir t)
 (feebleline-show-time nil)
 (feebleline-show-previous-buffer nil)
 (mode-line-modes nil)
 :hook (emacs-startup . feebleline-mode))
(use-package marginalia :hook (after-init . marginalia-mode))
(use-package
 vertico
 :custom (vertico-count-format nil)
 :config (vertico-mode 1))
(use-package
 dashboard
 :hook
 ((after-init . dashboard-setup-startup-hook)
  (after-init . dashboard-refresh-buffer))
 :config
 (add-to-list 'recentf-exclude "/nix/store")
 (add-to-list 'recentf-exclude "ido.last")
 :custom
 (initial-buffer-choice (lambda () (get-buffer-create "*dashboard*")))
 (dashboard-banner-official-png nil)
 (dashboard-startup-banner nil)
 (dashboard-banner-logo-png nil)
 (dashboard-footer-messages nil)
 (dashboard-projects-backend 'project-el)
 (dashboard-items '((recents . 20) (projects . 20) (agenda . 20)))
 (dashboard-banner-logo-title ""))
(use-package
 undo-tree
 :after (evil)
 :hook (after-init . global-undo-tree-mode))
(use-package centered-cursor-mode :config (centered-cursor-mode +1))
(use-package magit :bind ("C-x g" . magit-status))
(use-package
 git-commit
 :hook
 ((git-commit-mode . flyspell-mode)
  (git-commit-mode . git-commit-save-message)
  (git-commit-mode . turn-on-auto-fill)))
(use-package git-gutter :config (global-git-gutter-mode +1))
(use-package default-text-scale)

(setq mouse-wheel-progressive-speed nil
      mouse-wheel-scroll-amount '(1 ((shift) . 1) ((control) . nil)))
(define-key
 global-map [(control +)] (function default-text-scale-increase))
(define-key
 global-map [(control -)] (function default-text-scale-decrease))
(define-key
 global-map
 [(control mouse-4)]
 (function default-text-scale-increase))
(define-key
 global-map
 [(control mouse-5)]
 (function default-text-scale-decrease))
(require 'uniquify)
(use-package
 winum
 :after (evil)
 :hook ((after-init . winum--clear-mode-line) (after-init . winner-mode))
 :config
 (defconst evil-winner-key (kbd "C-w")
   "Evil winner prefix")
 (evil-global-set-key 'insert evil-winner-key 'evil-window-map)
 (evil-global-set-key 'emacs evil-winner-key 'evil-window-map)
 (evil-global-set-key 'normal evil-winner-key 'evil-window-map)
 (winum-mode +1)
 (define-key 'evil-window-map (kbd "/") 'switch-to-buffer)
 (define-key
  'evil-window-map (kbd "C-/") 'switch-to-buffer-other-window)
 (define-key 'evil-window-map (kbd "1") 'winum-select-window-1)
 (define-key 'evil-window-map (kbd "1") 'winum-select-window-1)
 (define-key 'evil-window-map (kbd "2") 'winum-select-window-2)
 (define-key 'evil-window-map (kbd "3") 'winum-select-window-3)
 (define-key 'evil-window-map (kbd "4") 'winum-select-window-4)
 (define-key 'evil-window-map (kbd "5") 'winum-select-window-5)
 (define-key 'evil-window-map (kbd "6") 'winum-select-window-6)
 (define-key 'evil-window-map (kbd "7") 'winum-select-window-7)
 (define-key 'evil-window-map (kbd "8") 'winum-select-window-8)
 (define-key 'evil-window-map (kbd "9") 'winum-select-window-9)
 (define-key 'evil-window-map (kbd "0") 'winum-select-window-0-or-10)
 (winner-mode +1)
 (define-key 'evil-window-map (kbd "s") 'split-window-vertically)
 (define-key 'evil-window-map (kbd "v") 'split-window-horizontally)
 (define-key 'evil-window-map (kbd "u") 'winner-undo)
 (define-key 'evil-window-map (kbd "l") 'winner-undo)
 (define-key
  'evil-window-map (kbd "<left>") 'shrink-window-horizontally)
 (define-key
  'evil-window-map (kbd "<right>") 'enlarge-window-horizontally)
 (define-key 'evil-window-map (kbd "<down>") 'shrink-window)
 (define-key 'evil-window-map (kbd "<up>") 'enlarge-window)
 (setq-default windmove-wrap-around t)
 (windmove-default-keybindings)
 (windmove-swap-states-default-keybindings)
 (setq
  idle-update-delay 2
  jit-lock-defer-time 0
  jit-lock-stealth-time 0.2
  jit-lock-stealth-verbose nil)
 ;; Prefer vertical splits
 ;; https://www.emacswiki.org/emacs/HorizontalSplitting
 (setq-default split-width-threshold 160)
 (setq-default use-dialog-box nil))

(use-package
 ace-window
 :custom
 (define-key 'evil-window-map (kbd "a") 'ace-window)
 (window-divider-default-right-width 3)
 (window-divider-default-places 'right-only)
 :config (window-divider-mode +1))
(defun switch-to-previous-buffer ()
  "Switch to previous buffer."
  (interactive)
  (switch-to-buffer (other-buffer (current-buffer) 1)))
(defmacro hook! (hook &rest body)
  "Extend HOOK with BODY (wrapped in lambda if necessary)."
  (cond
   ((and (eq (length body) 1) (symbolp (first body)))
    (let ((s (first body)))
      `(add-hook ',hook ',s)))
   (t
    `(add-hook ',hook (lambda () ,@body)))))
(hook! shell-mode-hook
       (local-set-key (kbd "C-c s") 'delete-window)
       (local-set-key (kbd "C-c C-s") 'delete-window)
       (local-set-key (kbd "C-l") 'comint-clear-buffer)
       (ansi-color-for-comint-mode-on))
(defmacro on-the-side (side &optional size)
  "Buffer placed on SIDE.  SIZE is either width or height."
  (or size (setq size 0.3))
  (list
   'quote
   (list
    (list 'display-buffer-in-side-window) (cons 'side side)
    (if (or (eq side 'right) (eq side 'left))
        (cons 'window-width size)
      (cons 'window-height size)))))
;; Decrease font size in side buffers
(defun symbol-concat (&rest args)
  "Concatenates symbolic ARGS."
  (intern (apply 'concat (mapcar (lambda (x) (symbol-name x)) args))))

(cl-letf ((text-dec
           (lambda ()
             (if (eq window-system 'x)
                 (text-scale-decrease 1)))))
  (cl-loop
   for mode in
   '(Man
     Info
     help
     shell
     eshell
     xref--xref-buffer
     magit-status
     ielm
     ibuffer
     ensime-inf
     completion-list
     pdf-outline-buffer
     sbt)
   do (add-hook (symbol-concat mode '-mode-hook) text-dec)))
(use-package
 which-key
 :custom
 (which-key-sort-order nil)
 (which-key-side-window-max-height 0.33)
 :config (which-key-mode +1))
(defmacro if-any-window-system (&rest body)
  "If Emacs running in graphical enviroment execute BODY."
  `(if (not (eq (window-system) 'nil))
       (progn
         ,@body)))
(defun ai:setup-frame (frame)
  "Setup a FRAME."
  (setq frame (or frame (selected-frame)))
  (if-any-window-system
   (when (display-graphic-p)
     (set-frame-parameter frame 'internal-border-width 2)
     (fringe-mode '(14 . 7))))
  (if (>= emacs-major-version 27)
      (set-fontset-font
       t
       '(#x1f000 . #x1faff)
       (font-spec :family "Noto Color Emoji"))))
(add-hook 'after-init-hook (lambda () (ai:setup-frame nil)) t)
(add-to-list 'after-make-frame-functions #'ai:setup-frame)
(use-package
 jc-themes
 ;builtin
 :when (file-exists-p "@jc@")
 :after (dired dired-subtree evil)
 :load-path "@jc@"
 :config
 (add-hook
  'after-init-hook ;;
  #'(lambda () (load-theme 'jc-themes-random t))))
(require 'eshell)
(require 'shell)
(require 'ansi-color)
(setq-default eshell-where-to-jump 'begin)
(setq-default eshell-review-quick-commands nil)
(setq-default eshell-smart-space-goes-to-end t)
(setq-default
 comint-input-sender-no-newline t
 comint-prompt-read-only t
 eshell-where-to-jump 'begin
 eshell-review-quick-commands nil)
(defun eshell-maybe-bol ()
  "Go to the beginning of current line."
  (interactive)
  (let ((p (point)))
    (eshell-bol)
    (if (= p (point))
        (beginning-of-line))))
(add-hook
 'eshell-mode-hook
 '(lambda () (define-key eshell-mode-map "\C-a" 'eshell-maybe-bol)))
(require 'em-smart)
(defun eshell-here ()
  "Go to eshell and set current directory to the buffer's directory."
  (interactive)
  (let ((dir
         (file-name-directory
          (or (buffer-file-name) default-directory))))
    (eshell)
    (eshell/pushd ".")
    (cd dir)
    (goto-char (point-max))
    (eshell-kill-input)
    (eshell-send-input)))
(setq-default eshell-banner-message "")
(eval-after-load 'em-ls
  '(progn
     (defun ted-eshell-ls-find-file-at-point (point)
       "RET on Eshell's `ls' output to open files."
       (interactive "d")
       (find-file
        (buffer-substring-no-properties
         (previous-single-property-change point 'help-echo)
         (next-single-property-change point 'help-echo))))
     (defun pat-eshell-ls-find-file-at-mouse-click (event)
       "Middle click on Eshell's `ls' output to open files.
       From Patrick Anderson via the wiki."
       (interactive "e")
       (ted-eshell-ls-find-file-at-point
        (posn-point (event-end event))))
     (let ((map (make-sparse-keymap)))
       (define-key
        map (kbd "<return>") 'ted-eshell-ls-find-file-at-point)
       (define-key
        map (kbd "<mouse-1>") 'pat-eshell-ls-find-file-at-mouse-click)
       (defvar ted-eshell-ls-keymap map))
     (defadvice eshell-ls-decorated-name
         (after ted-electrify-ls activate)
       "Eshell's `ls' now lets you click or RET on file names to open them."
       (add-text-properties 0 (length ad-return-value)
                            (list
                             'help-echo
                             "RET, mouse-1: visit this file"
                             'mouse-face
                             'highlight
                             'keymap
                             ted-eshell-ls-keymap)
                            ad-return-value)
       ad-return-value)))
(setq-default shell-font-lock-keywords
              '(("[ \t]\\([+-][^ \t\n]+\\)" . font-lock-comment-face)
                ("^[a-zA-Z]+:" . font-lock-doc-face)
                ("^\\[[^\\]]+\\]:" . font-lock-doc-face)
                ("\\[INFO\\]" . font-lock-doc-face)
                ("\\[WARNING\\]" . font-lock-warning-face)
                ("\\[ERROR\\]" . compilation-error-face)
                ("^\\[[1-9][0-9]*\\]" . font-lock-string-face)))
(custom-set-variables
 '(ansi-color-names-vector
   ["black"
    "red4"
    "green4"
    "yellow4"
    "blue4"
    "magenta4"
    "cyan4"
    "gray44"]))
(add-hook 'shell-mode-hook 'ansi-color-for-comint-mode-on)
(add-hook 'eshell-mode-hook 'ansi-color-for-comint-mode-on)
(use-package bash-completion :config (bash-completion-setup))
(require 'em-tramp)
(setq eshell-prefer-lisp-functions t)
(setq eshell-prefer-lisp-variables t)
(add-to-list 'eshell-modules-list 'eshell-tramp)
(setq password-cache t)
(setq password-cache-expiry 3600)
(defun ai/iimage-mode-refresh--eshell/cat (orig-fun &rest args)
  "Display image when using cat on it."
  (let ((image-path
         (cons default-directory iimage-mode-image-search-path)))
    (dolist (arg args)
      (let ((imagep nil)
            file)
        (with-silent-modifications
          (save-excursion
            (dolist (pair iimage-mode-image-regex-alist)
              (when (and (not imagep)
                         (string-match (car pair) arg)
                         (setq file (match-string (cdr pair) arg))
                         (setq file (locate-file file image-path)))
                (setq imagep t)
                (add-text-properties 0 (length arg)
                                     `(display
                                       ,(create-image file)
                                       modification-hooks
                                       (iimage-modification-hook))
                                     arg)
                (eshell-buffered-print arg)
                (eshell-flush)))))
        (when (not imagep)
          (apply orig-fun (list arg)))))
    (eshell-flush)))
(advice-add 'eshell/cat :around #'ai/iimage-mode-refresh--eshell/cat)
(defun eshell/clear ()
  "Clear the eshell buffer."
  (let ((inhibit-read-only t))
    (erase-buffer)))

;; C
(require 'elide-head)
(use-package c-eldoc)
(use-package
 ccls
 :custom (c-basic-offset 4)
 :hook
 (c-mode-hook . c-turn-on-eldoc-mode)
 (c-mode-common-hook . elide-head))
(use-package lsp-mode :hook (cpp-mode . lsp) (java-mode . lsp))
(use-package dap-mode :after (lsp))
(use-package
 lsp-metals
 :after (lsp)
 :custom
 (lsp-metals-server-args
  '("-J-Dmetals.allow-multiline-string-formatting=off"))
 :hook (scala-mode . lsp))
(use-package
 lsp-java
 :after (lsp)
 :hook
 (java-mode . lsp)
 (java-mode . lsp-java-lens-mode))
(use-package
 ansi-color
 ;builtin
 :init
 (defun colorize-compilation-buffer ()
   (read-only-mode -1)
   (ansi-color-apply-on-region compilation-filter-start (point))
   (read-only-mode +1))
 :hook (compilation-filter . colorize-compilation-buffer))
;;; Haskell
(use-package lsp-haskell :after (lsp) :hook (haskell-mode . lsp))
(use-package
 haskell-mode
 :custom (haskell-font-lock-symbols t)
 :hook
 ((haskell-mode . turn-on-haskell-doc-mode)
  (haskell-mode . turn-on-haskell-indent)
  (haskell-mode . interactive-haskell-mode)))
;;; Perl
(use-package raku-mode)
;; https://raw.github.com/illusori/emacs-flymake-perlcritic/master/flymake-perlcritic.el
(setq flymake-perlcritic-severity 5)
(use-package flymake-cursor)
(defmacro save-current-point (body)
  "Save current point; execute BODY; go back to the point."
  `(let ((p (point)))
     (progn
       ,body
       (goto-char p))))
(defmacro shell-command-on-buffer (&rest args)
  "Mark the whole buffer; pass ARGS to `shell-command-on-region'."
  `(shell-command-on-region (point-min) (point-max) ,@args))
(use-package
 font-lock
 ;builtin
 :config
 (add-hook
  'prog-mode-hook
  (lambda ()
    (hs-minor-mode +1)
    (hs-hide-initial-comment-block))))
(use-package
 cperl-mode
 ;builtin
 :after (evil)
 :mode "\\.pl\\'"
 :init
 (defun perltidy-buffer ()
   "Run perltidy on the current buffer."
   (interactive)
   (if (eshell-search-path "perltidy")
       (save-current-point
        (shell-command-on-buffer
         "perltidy -q"
         (not :output-buffer)
         :replace))))
 (defun perltidy-on-save ()
   (add-hook 'before-save-hook 'perltidy-buffer

             :append
             :local))
 :bind
 (:map
  cperl-mode-map ("C-c C-c" . cperl-perldoc-at-point) ("M-." . ffap))
 :hook
 (perl-mode . cperl-mode)
 (cperl-mode . perltidy-on-save)
 :custom
 (cperl-indent-level 4)
 (cperl-continued-statement-offset 0)
 (cperl-extra-newline-before-brace t)
 :config
 (evil-define-key
  'normal perl-mode-map (kbd "g d") 'cperl-perldoc-at-point))
;;; Org
(use-package org :after (evil) :config (setq-default org-log-done t))
(use-package
 org-bullets
 :after (org)
 :hook (org-mode . org-bullets-mode))
(use-package general :after evil :custom (general-emit-autoloads nil))
(general-define-key
 :states '(normal insert motion emacs)
 :keymaps 'override
 :prefix-map 'lead-map
 :prefix "SPC"
 :non-normal-prefix "M-q")
(general-create-definer lead-def :keymaps 'lead-map)
(general-def universal-argument-map "SPC u" 'universal-argument-more)
(lead-def ;;
 "SPC" '("M-x" . execute-extended-command)
 ;;
 "c" (cons "code" (make-sparse-keymap))
 ;;
 "cb" 'flymake-show-buffer-diagnostics ;;
 "cc" 'compile ;;
 "cn" 'next-error ;;
 "cp" 'previous-error ;;
 "cr" 'recompile ;;
 "cx" 'kill-compilation ;;
 "c=" 'indent-region-or-buffer ;:
 "s" (cons "shell" (make-sparse-keymap))
 ;;
 "ss" 'project-shell ;;
 "st" 'vterm ;;
 "sv" 'project-vc-dir ;;
 "sc" 'project-shell-command ;;
 "sg" 'project-search ;;
 "se" 'project-eshell ;;
 "sa" 'project-async-shell-command ;;
 "sf" 'project-find-file ;;
 "sd" 'project-find-dir ;;
 "sg" 'project-find-regexp ;;
 "g" (cons "git" (make-sparse-keymap))
 ;;
 "gg" 'magit-dispatch ;;
 "gs" 'magit-status ;;
 )
(general-def
 "M-j"
 (defun scroll-other-window-next-line (&optional arg)
   (interactive "P")
   (scroll-other-window (or arg 1)))
 "M-k"
 (defun scroll-other-window-previous-line (&optional arg)
   (interactive "P")
   (scroll-other-window (- (or arg 1)))))
(use-package
 restart-emacs
 :after (general)
 :config
 (lead-def "Sr" 'restart-emacs "SR" 'restart-emacs-start-new-emacs))
(use-package
 notmuch
 :when (file-exists-p "~/Maildir")
 :after (general)
 :init
 (lead-def ;;
  "m m i"
  '(lambda ()
     (interactive)
     (notmuch-tree "is:inbox"))
  "m m p"
  '(lambda ()
     (interactive)
     (notmuch-tree "is:inbox and is:private"))
  "m m g"
  '(lambda ()
     (interactive)
     (notmuch-tree "is:inbox and is:github"))
  "m m s"
  '(lambda ()
     (interactive)
     (notmuch-tree))))
(use-package
 nix-mode
 :hook (after-init . nix-prettify-global-mode)
 :config (add-hook 'before-save-hook 'nix-format-before-save))
(use-package
 elisp-autofmt ;builtin
 :when (file-exists-p "@autofmt@")
 :load-path "@autofmt@"
 :commands (elisp-autofmt-mode elisp-autofmt-buffer)
 :hook (emacs-lisp-mode . elisp-autofmt-mode))
(use-package elisp-lint)
(use-package elisp-refs)
(use-package
 eros
 :hook (lisp-mode . eros-mode) (emacs-lisp-mode . eros-mode))
;; Clojure
(use-package
 cider
 :custom ;;
 (cider-repl-use-pretty-printing t)
 (cider-repl-display-help-banner nil))
;; Common Lisp
(use-package sly)
(use-package sly-asdf)
(use-package sly-quicklisp)
(use-package sly-repl-ansi-color)
(use-package sly-macrostep)
;; TeX
(use-package xenops :hook (latex-mode . xenops-mode))


;;; Dired
(use-package
 dired
 ;builtin
 :after (evil)
 :init (require' dired-x)
 :custom (dired-omit-files "^.$\\|^#\\|~$\\|^.#")
 :config
 (defun kill-all-dired-buffers ()
   "Kill all dired buffers."
   (interactive)
   (save-excursion
     (let ((count 0))
       (dolist (buffer (buffer-list))
         (set-buffer buffer)
         (when (equal major-mode 'dired-mode)
           (setq count (1+ count))
           (kill-buffer buffer)))
       (message "Killed %i dired buffer(s)." count))))
 (add-hook 'dired-mode-hook 'hl-line-mode)
 (add-hook 'dired-mode-hook 'dired-omit-mode)
 (evil-define-key
  'normal dired-mode-map ;;
  (kbd "g h") 'dired-hide-details-mode ;;
  (kbd "g o") 'dired-omit-mode ;;
  (kbd "C-<return>") 'dired-subtree-insert ;;
  (kbd "M-<return>") 'dired-insert-subdir ;;
  (kbd ",") 'dired-insert-subdir ;;
  (kbd "C-o") 'dired-up-directory ;;
  (kbd ".") 'dired-up-directory)
 (evil-define-key
  'insert wdired-mode-map (kbd "<return>") 'wdired-finish-edit)
 (evil-define-key
  'normal wdired-mode-map (kbd "<return>") 'wdired-exit)
 (define-key dired-mode-map "v" 'dired-x-find-file)
 (define-key dired-mode-map "V" 'dired-view-file)
 (define-key dired-mode-map "j" 'dired-next-line)
 (define-key dired-mode-map "J" 'dired-goto-file)
 (define-key dired-mode-map "k" 'dired-previous-line)
 (define-key dired-mode-map "K" 'dired-do-kill-lines)
 (setq dired-dwim-target t))
(use-package
 dired-subtree
 :after (dired)
 :init
 (bind-key "<tab>" #'dired-subtree-toggle dired-mode-map)
 (bind-key "<backtab>" #'dired-subtree-cycle dired-mode-map))
(define-key global-map "\C-x\C-d" 'dired-jump)
(define-key global-map "\C-x\C-j" 'dired-jump-other-window)
(require 'wdired)
(add-hook
 'dired-load-hook
 (lambda ()
   ;; Set dired-x global variables here.  For example:
   (setq wdired-allow-to-change-permissions t)
   (setq dired-x-hands-off-my-keys nil)
   (load "dired-x")))
(defun dired-sort* ()
  "Sort Dired listings with directories first."
  (save-excursion
    (let (buffer-read-only)
      (forward-line 2) ;; beyond dir. header
      (sort-regexp-fields t "^.*$" "[ ]*." (point) (point-max)))
    (set-buffer-modified-p nil)))
(defadvice dired-readin
    (after dired-after-updating-hook first () activate)
  "Sort Dired listings with directories first before adding marks."
  (dired-sort*))

(use-package
 emms
 :after (hydra evil dired)
 :init
 (require 'emms-setup)
 (require 'emms-cue)
 (require 'emms-player-mpv)
 (add-to-list 'emms-player-list 'emms-player-mpv)
 (evil-define-key 'normal dired-mode-map (kbd "g p") 'emms-play-dired)
 :config (emms-player-mpd-connect))
;; (defhydra emms-control () ;;
;;   "
;; %s(let ((inhibit-message t)) (emms-show))

;; " ;;
;;   ("p" emms-pause "pause")
;;   ("." emms-seek-forward    ">>>")
;;   ("," emms-seek-backard   "<<<")
;;   ("J" emms-cue-next        ">")
;;   ("K" emms-cue-previous    "<")
;;   ("j" emms-player-mpd-next ">>")
;;   ("k" emms-player-mpd-previous ">>")
;;   ("0" emms-volume-raise  "^")
;;   ("9" emms-volume-lower  "v")
;;   ("i" emms-show "v"))
;; (lead-def "a" 'emms-control/body)


;; Text
(use-package
 prettify-greek
 :config (global-prettify-symbols-mode -1)
 (setq prettify-symbols-alist
       (append
        prettify-symbols-alist
        prettify-greek-lower
        prettify-greek-upper))
 (global-prettify-symbols-mode +1))
(use-package rainbow-mode)
(use-package ack :config (lead-def "ta" 'ack))
(use-package
 flyspell ;builtin
 :config
 (require 'ispell)
 (setq ispell-program-name
       (or (executable-find "hunspell") (executable-find "ispell")))
 (ispell-change-dictionary "en_GB")
 (add-hook 'text-mode-hook (lambda () (flyspell-mode 1)))
 (add-hook 'org-mode-hook (lambda () (flyspell-mode 1)))
 (add-hook 'prog-mode-hook (lambda () (flyspell-prog-mode))))
;; Org
(use-package
 calendar ;builtin
 :config (require 'holidays))
(use-package vterm)
(use-package ag :config (lead-def "tg" 'ag))
(use-package wgrep :after ag)
(use-package wgrep-ag :after wgrep)
;; WM
(use-package
 exwm
 :when (eq window-system 'x)
 :custom
 (exwm-replace nil)
 (exwm-workspace-number 6)
 (exwm-workspace-show-all-buffers t)
 :config
 (require 'exwm-systemtray)
 (exwm-systemtray-enable)
 (require 'exwm-config)
 (exwm-config-ido)
 (add-hook
  'exwm-mode-hook
  #'(lambda () (local-set-key (kbd "C-w") 'evil-window-map)))

 (define-key 'evil-window-map (kbd "C-q") 'exwm-input-send-next-key)
 (defun exwm-rename-buffer ()
   (interactive)
   (exwm-workspace-rename-buffer
    (concat
     exwm-class-name ":"
     (if (<= (length exwm-title) 50)
         exwm-title
       (concat (substring exwm-title 0 49) "...")))))
 ;; Add these hooks in a suitable place (e.g., as done in exwm-config-default)
 (add-hook 'exwm-update-class-hook 'exwm-rename-buffer)
 (add-hook 'exwm-update-title-hook 'exwm-rename-buffer)
 (add-hook
  'exwm-update-title-hook
  (lambda ()
    (when (or (not exwm-instance-name)
              (string-prefix-p "sun-awt-X11-" exwm-instance-name)
              (string= "gimp" exwm-instance-name))
      (exwm-workspace-rename-buffer exwm-title))))
 (exwm-input-set-key (kbd "s-r") #'exwm-reset)
 (exwm-input-set-key (kbd "s-w") #'exwm-workspace-switch)
 (exwm-input-set-key (kbd "s-m") #'exwm-workspace-move-window)
 (setq-default exwm-input-prefix-keys
               '(?\C-x ?\C-u ?\C-h ?\M-x ?\M-` ?\M-& ?\M-: ?\C-w))
 (cl-loop
  for i from 1 to exwm-workspace-number do
  (exwm-input-set-key
   (kbd (format "s-%d" (% i 10)))
   `(lambda ()
      (interactive)
      (exwm-workspace-switch-create (- ,i 1)))))
 (cl-loop
  for i from 1 to exwm-workspace-number do
  (exwm-input-set-key
   (kbd (format "s-s %d" (% i 10)))
   `(lambda ()
      (interactive)
      (exwm-workspace-move-window (- ,i 1)))))
 (exwm-input-set-key
  (kbd "s-&")
  (lambda (command)
    (interactive (list (read-shell-command "$ ")))
    (start-process-shell-command command nil command)))
 (exwm-enable)
 (exwm-init))

(use-package
 olivetti
 :after (evil)
 :config (define-key 'evil-window-map (kbd "z") 'olivetti-mode))

(use-package
 emacs
 ;builtin
 :init
 (setq completion-cycle-threshold 3)
 (setq read-extended-command-predicate
       #'command-completion-default-include-p)
 (setq tab-always-indent 'complete))
(use-package
 perspective
 :bind
 (("C-x b" . persp-switch-to-buffer*) ("C-x k" . persp-kill-buffer*))
 :hook (kill-emacs . persp-state-save)
 :custom (persp-suppress-no-prefix-key-warning t)
 :config (persp-mode))
(use-package bufler)
(use-package perspective-exwm :after (exwm))
(use-package exwm-mff :after (exwm) :hook (exwm-init . exwm-mff-mode))
(add-hook
 'vterm-mode-hook (lambda () (setq evil-default-state 'emacs)))
(use-package fringe-current-line
  :init
 (define-fringe-bitmap 'wave
    (vector #b00000000
            #b00000000
            #b00011000
            #b00100100
            #b00100100
            #b00011000
            #b00000000
            #b00000000
            )
    nil nil 'center)
 (define-fringe-bitmap 'arrow-indicator
    (vector #b00111100
            #b01111110
            #b11100111
            #b11000011
            #b11000011
            #b11100111
            #b01111110
            #b00111100)
    nil nil 'center)
  :custom
  (flycheck-indication-mode 'right-fringe)
  :config
  (setq fcl-fringe-bitmap 'arrow-indicator)
  (setq-default indicate-empty-lines t)

  (setcdr (assq 'empty-line fringe-indicator-alist) 'wave)

  :hook (after-init . global-fringe-current-line-mode)
  )
(use-package flycheck
  :config
  (define-fringe-bitmap 'flycheck-fringe-indicator
    (vector #b0000000000000000
            #b0000000000000000
            #b0111111111111110
            #b1111111111111111
            #b1111111111111111
            #b1111111111111111
            #b1111111111111111
            #b0111111111111110
            #b0000000000000000
            #b0000000000000000)
    nil nil 'center)
  :custom (flycheck-indication-mode 'right-fringe)
  :hook (after-init . global-flycheck-mode)
  :config
  (flycheck-define-error-level 'error
    :severity 2
    :overlay-category 'flycheck-error-overlay
    :fringe-bitmap 'flycheck-fringe-indicator
    :fringe-face 'flycheck-fringe-error)
  (flycheck-define-error-level 'warning
    :severity 1
    :overlay-category 'flycheck-warning-overlay
    :fringe-bitmap 'flycheck-fringe-indicator
    :fringe-face 'flycheck-fringe-warning)
  (flycheck-define-error-level 'info
    :severity 0
    :overlay-category 'flycheck-info-overlay
    :fringe-bitmap 'flycheck-fringe-indicator
    :fringe-face 'flycheck-fringe-info))
(use-package unicode-fonts)
(use-package dr-racket-like-unicode
  :hook (prog-mode . dr-racket-like-unicode-mode))
(use-package auto-highlight-symbol
  :custom
  (ahs-idle-interval 0.1)
  :config
  (lead-def "t h" 'auto-highlight-symbol-mode))
(provide 'init.el)

;;; init.el ends here
