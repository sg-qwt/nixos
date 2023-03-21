(eval-when-compile
  (require 'use-package))

(use-package modus-themes
  :custom
  (modus-themes-bold-constructs t)
  :config
  (setq modus-themes-common-palette-overrides modus-themes-preset-overrides-intense)
  (load-theme 'modus-operandi t))

(use-package emacs
  :after evil
  :custom
  (inhibit-startup-message t)

  (custom-file (concat user-emacs-directory "custom.el"))

  (backup-directory-alist `((".*" . ,temporary-file-directory)))

  (auto-save-file-name-transforms `((".*" ,temporary-file-directory t)))

  (auto-save-list-file-prefix (concat temporary-file-directory "auto-saves-list/.saves-"))

  (display-line-numbers 'relative)

  (use-dialog-box nil)

  (enable-recursive-minibuffers t)
  (minibuffer-prompt-properties '(read-only t cursor-intangible t face minibuffer-prompt))

  :hook
  (emacs-startup . (lambda () (find-file (concat user-emacs-directory "init.el"))))
  :config
  (load custom-file t)
  (savehist-mode 1)
  (recentf-mode 1)

  (menu-bar-mode 0)
  (tool-bar-mode 0)
  (scroll-bar-mode 0)
  (minibuffer-depth-indicate-mode 1)

  )

(use-package evil
  :demand t
  :hook
  (window-configuration-change . evil-normalize-keymaps)
  :custom
  (evil-want-integration t)
  (evil-want-keybinding nil)
  (evil-want-fine-undo t)
  (evil-want-C-u-scroll t)
  (evil-want-C-d-scroll t)
  (evil-undo-system 'undo-redo)
  (evil-search-module 'evil-search)
  
  :config
  (evil-mode 1))

(use-package evil-collection
  :after evil
  :custom
  (evil-collection-setup-minibuffer t)
  :config
  (evil-collection-init))

(use-package command-log-mode
  :commands (global-command-log-mode)
  :custom
  (command-log-mode-auto-show t))

(use-package general
  :after evil
  :config

  (defun qqq/consult-buffer-p ()
    (interactive)
    (setq unread-command-events (append unread-command-events (list ?p 32)))
    (consult-buffer)) 

  (general-evil-setup t)

  (general-auto-unbind-keys)

  (general-create-definer qqq/leader
    :states '(normal visual motion emacs insert)
    :keymaps 'override
    :prefix "SPC"
    :global-prefix "C-SPC")

  (general-create-definer qqq/local-leader
    :states '(normal visual motion emacs)
    :keymaps 'override
    :prefix ","
    :global-prefix "C-,")

  (qqq/leader "" nil)

  (qqq/local-leader "" nil)

  (qqq/leader
   "SPC" #'execute-extended-command)

  (qqq/leader
    "h s" #'describe-symbol
    "h k" #'describe-key
    "h v" #'describe-variable
    "h f" #'describe-function
    "h c" #'describe-char
    "h M" #'describe-mode
    "h m" #'consult-man
    "h i" #'consult-info
    "h l" #'global-command-log-mode)

  (qqq/leader
    "t m" #'consult-minor-mode-menu
    "t s" #'consult-theme
    "t t" #'modus-themes-toggle)

  (qqq/leader
    "s c" #'evil-ex-nohighlight
    "s b" #'consult-line
    "s p" #'consult-ripgrep
    )

  (qqq/leader
    "b b" #'consult-buffer
    "b p" #'qqq/consult-buffer-p
    )

  (qqq/leader
    "f f" #'find-file
    "f d" #'dired)

  (qqq/leader
    "q" #'save-buffers-kill-emacs)

  (qqq/local-leader
    "e b" #'eval-buffer
    "e f" #'eval-defun
    "e e" #'eval-expression)

  (qqq/local-leader
    with-editor-mode-map
    "c" #'with-editor-finish
    "k" #'with-editor-cancel))

(use-package consult
  :demand t
  :after vertico
  :custom
  (consult-narrow-key "<")
  :general
  (general-imap "M-/" 'completion-at-point)
  :config
  (setq completion-in-region-function
	(lambda (&rest args)
	  (apply (if vertico-mode
		     #'consult-completion-in-region
		   #'completion--in-region)
		 args))))

(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles basic partial-completion)))))

(use-package magit
  :general
  (qqq/leader
    "g s" #'magit-status))

(use-package marginalia
  :after evil
  :demand t
  :general
  (general-def
    '(normal insert)
    minibuffer-local-map
    "M-A" 'marginalia-cycle)
  :config
  (marginalia-mode 1))

(use-package vertico
  :demand t
  :hook
  (minibuffer-setup . cursor-intangible-mode)
  :custom
  (vertico-resize t)
  (vertico-cycle t)
  :config
  (vertico-mode 1)
  :general
  (general-def
    '(normal insert)
   vertico-map
   "C-j" 'vertico-next
   "C-k" 'vertico-previous
   "C-l" 'vertico-insert
   "C-p" 'previous-history-element
   "C-n" 'next-history-element 
   "C-h" 'vertico-directory-delete-word
   "C-f" 'vertico-scroll-up
   "C-b" 'vertico-scroll-down
   "C-]" 'top-level
   "C-r" 'consult-history)
  (general-def
    '(normal)
    vertico-map
    "G" 'vertico-last
    "g g" 'vertico-first
    )
  )

(use-package nix-mode
  :mode "\\.nix\\'")

