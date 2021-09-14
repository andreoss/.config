;;; Commentary:
;;;  Minimal vi-like Emacs configuration.
;;;
;;;  $ emacs -Q -nw -l mini.el
;;;
;;; Code:
;; Visual bell
(setq-default visible-bell t)
;; Do not display mode-line
(setq-default mode-line-format nil)
;; Do not show startup screen
(setq-default inhibit-startup-screen  t)
;; Scratch buffer
(setq-default initial-scratch-message
              (format ";; %.5f s\n" (float-time
                  (time-subtract after-init-time before-init-time))))
;; Load extra files
(defvar dotfiles-directory-name
  (file-name-directory (or (buffer-file-name) load-file-name))
  "Location of main Emacs configuration files.")
(setq-default viper-expert-level '5)
(setq-default viper-inhibit-startup-message 't)
(setq-default viper-mode +1)

;; Viper
(require 'viper)
(viper-mode)
(define-key viper-vi-basic-map (kbd "v") 'nil)
(define-key viper-vi-basic-map (kbd "V") 'nil)
(define-key viper-vi-local-user-map (kbd "g f") 'find-file-at-point)
(define-key viper-vi-local-user-map (kbd "g d") 'xref-find-definitions)
(define-key viper-vi-local-user-map (kbd "Z Z") 'save-buffers-kill-emacs)
(define-key viper-vi-local-user-map (kbd ";") 'viper-ex)

(defmacro if-bound (sym &rest body)
  "If SYM is bound, execute BODY."
  `(if (fboundp ',sym) (progn ,@body)))

;; Minimalize UI
(if-bound menu-bar-mode   (menu-bar-mode -1))
(if-bound tool-bar-mode   (tool-bar-mode -1))
(if-bound scroll-bar-mode (scroll-bar-mode +1))

;; Adopt dired for viper
(eval-after-load "dired"
  '(progn
    (define-key dired-mode-map "v" 'dired-find-file)
    (define-key dired-mode-map "V" 'dired-view-file)
    (define-key dired-mode-map "j" 'dired-next-line)
    (define-key dired-mode-map "J" 'dired-goto-file)
    (define-key dired-mode-map "k" 'dired-previous-line)
    (define-key dired-mode-map "K" 'dired-do-kill-lines)))
;;
(defalias 'yes-or-no-p 'y-or-n-p)
(ido-mode +1)
;; Globals
;; Disable code coloring
(global-font-lock-mode -1)
(global-eldoc-mode +1)
(if-bound global-aggressive-indent-mode
  (global-aggressive-indent-mode +1))
(global-visual-line-mode -1)
(global-auto-revert-mode +1)
(global-display-line-numbers-mode -1)
(global-reveal-mode +1)
(global-prettify-symbols-mode +1)
(setq-default show-paren-style 'parenthesis)
(show-paren-mode +1)
(custom-set-faces '(viper-minibuffer-insert (nil)))

;; C-l moves current line on center of the buffer
(add-function
 :after (symbol-function 'recenter-top-bottom)
 #'viper-info-on-file)

;; Turn on line highliting on INS
(defun hl+ (&rest _) "Highlight current line ON." (hl-line-mode +1))
(defun hl- (&rest _) "Highlight current line OFF." (hl-line-mode -1))
(add-function :after (symbol-function 'viper-insert)            #'hl+)
(add-function :after (symbol-function 'viper-intercept-ESC-key) #'hl-)
(setq vc-follow-symlinks nil)
(require 'dired)
(require 'wdired)
(provide 'init-minimal)
;;; minimal-init ends here
