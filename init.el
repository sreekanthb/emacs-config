;;; init.el -- My Emacs init file

;;; Commentary:

;;; Code:
;; Intialize packahes
(eval-when-compile
  (require 'package)
  (unless (assoc-default "elpa" package-archives)
    (add-to-list 'package-archives '("elpa" . "https://elpa.gnu.org/packages/") t))
  (unless (assoc-default "melpa" package-archives)
    (add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t))
  (unless (assoc-default "org" package-archives)
    (add-to-list 'package-archives '("org" . "https://orgmode.org/elpa/") t))
  (package-initialize)
  (unless (package-installed-p 'use-package)
    (package-refresh-contents)
    (package-install 'use-package))
  (require 'use-package)
  (setq use-package-verbose t
        use-package-always-defer nil
	use-package-always-ensure t))

;; cool packages to have
(defvar package-list
  '(use-package smex flycheck ctable company cyberpunk-theme yasnippet
     exec-path-from-shell magit))

; install the missing packages
(dolist (package package-list)
  (unless (package-installed-p package)
      (package-install package)))

(eval-when-compile
  (require 'use-package))

;; disable defaults
(when (display-graphic-p)
  (progn
    (scroll-bar-mode -1)
    (tool-bar-mode   -1)))
(menu-bar-mode   -1)
(blink-cursor-mode 0)
(global-set-key [C-down-mouse-1] nil)
(setq ring-bell-function 'ignore)
(setq inhibit-startup-screen t)
(setq initial-scratch-message ";; Scratch that!")

;; enable cool defaults
(show-paren-mode 1)
(column-number-mode t)
(size-indication-mode 1)
(transient-mark-mode 1)
(delete-selection-mode 1)
(global-hl-line-mode 1)
(global-auto-revert-mode t)

;; keep all generated files in .cache directory, clean .emacs.d
(defvar cache-dir (concat user-emacs-directory ".cache/"))
(setq custom-file (concat cache-dir "emacs-custom.el"))
(unless (file-exists-p cache-dir)
  (make-directory cache-dir))
(load custom-file 'noerror)                                             ; put custom.el in .cache


(defun donot-litter ()
  "Do not litter .emacs.d with saves and backup files"
  (defvar autosave-dir
    (concat cache-dir "emacs-autosaves/"))

  (make-directory autosave-dir t)

  (defun auto-save-file-name-p (filename)
    (string-match "^#.*#$" (file-name-nondirectory filename)))

  (defun make-auto-save-file-name ()
    (concat autosave-dir
            (if buffer-file-name
                (concat "#" (file-name-nondirectory buffer-file-name) "#")
              (expand-file-name
               (concat "#%" (buffer-name) "#")))))

  (defvar backup-dir (concat cache-dir "emacs_backups/"))
  (setq backup-directory-alist (list (cons "." backup-dir)))
  ;;change eshell dir
  (setq-default eshell-directory-name (concat cache-dir "eshell/"))
  ;; move auto-save-list to .cache dir
  (setq auto-save-list-file-name (concat cache-dir "auto-save-list/")))
(donot-litter)

;; global settings
(setq tab-width 2
      indent-tabs-mode nil)
(setq require-final-newline t)
(fset 'yes-or-no-p 'y-or-n-p)
;; scrolling
(setq scroll-step 1
      scroll-margin 5
      scroll-conservatively 100000
      scroll-preserve-screen-position 1)

;;; ----- preferences ------
(set-language-environment "UTF-8")
(setq default-directory "~/")

;; font config
(when (find-font (font-spec :name "Iosevka"))
  (dolist (face '(default fixed-pitch))
    (set-face-attribute
     face nil
     :family "Iosevka"
     :width 'ultra-condensed
     :height 180)))

;; osx key modifiers
(when (eq system-type 'darwin)
  (setq mac-command-modifier 'meta)
  (setq mac-option-modifier 'super))

;; handy key bindings
(global-set-key "\M-+"  'text-scale-increase)
(global-set-key "\M-_"  'text-scale-decrease)
(global-set-key (kbd "C-|")  'toggle-frame-maximized)
(global-set-key "\C-cp" 'replace-string)
(global-set-key "\C-z" 'eshell)

;;; -------


;;; ------ extend built-in hooks ------
;; trim whitespaces
(add-hook 'before-save-hook 'delete-trailing-whitespace)

;; turn on flyspell
(add-hook 'text-mode-hook 'flyspell-mode)
(add-hook 'prog-mode-hook 'flyspell-prog-mode)

;; Highlight BUG FIXME TODO NOTE keywords in the source code.
(add-hook 'find-file-hook
	  (lambda()
	    (highlight-phrase "\\(BUG\\|FIXME\\|TODO\\|NOTE\\):" 'hi-red-b)))

;;; ------


;;; ------- packages configuration -------
(use-package company
  :config
  (define-key company-active-map (kbd "C-n") 'company-select-next-or-abort)
  (define-key company-active-map (kbd "C-p") 'company-select-previous-or-abort)
  (add-hook 'after-init-hook 'global-company-mode))

;; A GNU Emacs library to ensure environment variables inside Emacs look
;; the same as in the user's shell.
(use-package exec-path-from-shell
  :if (memq window-system '(mac ns))
  :config (exec-path-from-shell-initialize))

;; markdown mode
(use-package markdown-mode
  :ensure t
  :commands (markdown-mode gfm-mode)
  :mode (("README\\.md\\'" . gfm-studio)
	 ("\\.md\\'" . markdown-mode)
	 ("\\.markdown\\'" . markdown-mode))
  :init (setq markdown-command "multimarkdown"))

;; interactively do things with ido, ido-completing-read+, smex
(use-package ido
  :config
  (setq ido-enable-prefix nil
	ido-enable-flex-matching t
	ido-create-new-buffer 'always
	ido-use-filename-at-point 'guess
	ido-max-prospects 10
	ido-save-directory-list-file (concat cache-dir "ido.last")
	ido-default-file-method 'selected-window
	ido-auto-merge-work-directories-length nil)
  (ido-mode t)
  (ido-everywhere 1)
  ;; ido-completing-read+ - https://github.com/DarwinAwardWinner/ido-completing-read-plus
  (use-package ido-completing-read+
    :ensure t
    :config
    (ido-ubiquitous-mode 1))
  ;; Smex is a M-x enhancement for Emacs
  (use-package smex
    :config (smex-initialize)
    :bind (("M-x" . 'smex)
	   ("M-X" . 'smex-major-mode-commands))))

;; Modern on-the-fly syntax checking extension for GNU Emacs.
(use-package flycheck
  :config (global-flycheck-mode))

;; paredit for s-expression editing
(use-package paredit
  :ensure t
  :config
  (add-hook 'emacs-lisp-mode-hook 'paredit-mode)
  ;; enable in the *scratch* buffer
  (add-hook 'lisp-interaction-mode-hook 'paredit-mode)
  (add-hook 'ielm-mode-hook 'paredit-mode)
  (add-hook 'lisp-mode-hook 'paredit-mode)
  (add-hook 'eval-expression-minibuffer-setup-hook 'paredit-mode)
  ;; easier for in-REPL code typing
  (define-key paredit-mode-map (kbd "M-RET") 'paredit-newline))

;; multiple cursors for emacs - https://github.com/magnars/multiple-cursors.el
(use-package multiple-cursors
  :ensure t
  :config
  (setq mc/list-file (concat cache-dir ".mc-lists.el"))
  (global-set-key (kbd "C->") 'mc/mark-next-like-this)
  (global-set-key (kbd "C-<") 'mc/mark-previous-like-this)
  (global-set-key (kbd "C-c C-<") 'mc/mark-all-like-this))

(use-package magit
  :config
  (global-set-key (kbd "C-x g") 'magit-status))

;; smart-mode-line - https://github.com/Malabarba/smart-mode-line
(use-package smart-mode-line
  :ensure t
  :config
  (setq sml/theme 'dark)
  (setq sml/no-confirm-load-theme t)
  (sml/setup))

(use-package yasnippet
  :config
  (yas-global-mode 1)
  (global-set-key (kbd "M-i") 'yas-insert-snippet)
  (use-package yasnippet-snippets
    :ensure t))

;; clojure mode - https://github.com/clojure-emacs/clojure-mode
(use-package clojure-mode
  :ensure t
  :mode ("\\.edn\\'" . clojure-mode)    ; BUG: clojure-mode is enabled by default for .edn files
  :config
  (add-hook 'clojure-mode-hook #'paredit-mode))

;; CIDER - https://github.com/clojure-emacs/cider
;; Run this on first install, issue with cider package
(use-package cider
  :ensure t
  :config
  (setq cider-default-cljs-repl 'figwheel-main)
  (add-hook 'cider-repl-mode-hook #'paredit-mode))

;; Emacs plugin to show the current buffer's imenu entries in a seperate buffer
;; - https://github.com/bmag/imenu-list
(use-package imenu-list
  :ensure t
  :config
  (global-set-key (kbd "C-'") #'imenu-list-smart-toggle))

;; Quickly switch windows in emacs - https://github.com/abo-abo/ace-window
(use-package ace-window
  :ensure t
  :config
  (global-set-key (kbd "M-o") 'ace-window))

(use-package git-timemachine
  :ensure t)
;;; -------

;;; init.el ends here
