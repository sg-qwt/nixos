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
  (ring-bell-function #'ignore)
  (custom-file (concat user-emacs-directory "custom.el"))

  (backup-directory-alist `((".*" . ,temporary-file-directory)))

  (auto-save-file-name-transforms `((".*" ,temporary-file-directory t)))

  (auto-save-list-file-prefix (concat temporary-file-directory "auto-saves-list/.saves-"))

  (display-line-numbers 'relative)

  (use-dialog-box nil)

  (enable-recursive-minibuffers t)
  (minibuffer-prompt-properties '(read-only t cursor-intangible t face minibuffer-prompt))
  (global-auto-revert-non-file-buffers t)
  :config
  (load custom-file t)
  (savehist-mode 1)
  (recentf-mode 1)

  (menu-bar-mode 0)
  (tool-bar-mode 0)
  (scroll-bar-mode 0)

  (global-auto-revert-mode 1)

  (minibuffer-depth-indicate-mode 1)
  (add-to-list 'warning-suppress-types '(defvaralias))
  (setq qqq/garden-dir (substitute-in-file-name "${MYOS_FLAKE}/garden")))

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
  (defun qqq/ex-save-kill-buffer-and-close ()
    (interactive)
    (save-buffer)
    (kill-current-buffer))
  (defun qqq/ex-kill-buffer ()
    (interactive)
    (kill-current-buffer))
  (evil-ex-define-cmd "wq" 'qqq/ex-save-kill-buffer-and-close)
  (evil-ex-define-cmd "q" 'qqq/ex-kill-buffer)
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
    "SPC" #'execute-extended-command
    "/" #'consult-ripgrep)

  (qqq/leader
    :infix "h"
    "s" #'describe-symbol
    "k" #'describe-key
    "K" #'describe-keymap
    "v" #'describe-variable
    "f" #'describe-function
    "c" #'describe-char
    "M" #'describe-mode
    "m" #'woman
    "i" #'consult-info
    "l" #'global-command-log-mode)

  (qqq/leader
    "t m" #'consult-minor-mode-menu
    "t s" #'consult-theme
    "t t" #'modus-themes-toggle)

  (qqq/leader
    "s c" #'evil-ex-nohighlight
    "s b" #'consult-line
    "s p" #'project-find-file)

  (qqq/leader
    "b b" #'consult-buffer
    "b p" #'qqq/consult-buffer-p)

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
  (consult-preview-excluded-files '(".*\\.gpg$"))
  :general
  (general-imap "M-/" 'completion-at-point)
  :config
  (setq completion-in-region-function
	(lambda (&rest args)
	  (apply (if vertico-mode
		     #'consult-completion-in-region
		   #'completion--in-region)
		 args))))


(use-package cape
  :init
  (add-to-list 'completion-at-point-functions #'cape-dabbrev))

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

(use-package hcl-mode
  :mode "\\.tf\\'")

(use-package org-roam
  :demand t
  :general
  (qqq/leader
    :infix "o"
    "s" #'org-roam-db-sync
    "f" #'org-roam-node-find
    "i" #'org-roam-node-insert
    "t" #'org-roam-buffer-toggle
    "c" #'org-roam-capture
    "p" #'qqq/orm-capture-p)
  :custom
  (epa-file-encrypt-to "77EEFB04BFD81826")
  (epa-file-select-keys "auto")
  (org-directory qqq/garden-dir)
  (org-roam-directory qqq/garden-dir)
  (org-roam-file-exclude-regexp "templates/")
  :config
  (setq org-roam-capture-new-node-hook nil)
  (setq org-roam-capture-templates
	'(("d" "default" plain "%?"
	   :target (file+head "%<%Y%m%d%H%M%S>.org.gpg" "#+title: ${title}\n")
	   :unnarrowed t)
	  ("p" "pass" entry
	   (file "templates/pass.org")
	   :target (file "pass.org.gpg")
	   :empty-lines 1)))
  (setq org-roam-capture-ref-templates
	'(("b" "bookmark" entry
	   (file "templates/bookmark.org")
	   :target (file "bookmark.org.gpg")
	   :empty-lines 1)))
  (defun qqq/orm-capture-p ()
    (interactive)
    (org-roam-capture- :goto nil :keys "p" :node (org-roam-node-create)))

  (require 'org-roam-protocol)
  (org-roam-db-autosync-mode)
  (add-to-list 'display-buffer-alist
	       '("\\*org-roam\\*"
		 (display-buffer-in-direction)
		 (direction . right)
		 (window-width . 0.33)
		 (window-height . fit-window-to-buffer)))
  (defun qqq/return-t (orig-fun &rest args)
    t)
  (defun qqq/disable-yornp (orig-fun &rest args)
    (advice-add 'yes-or-no-p :around #'qqq/return-t)
    (advice-add 'y-or-n-p :around #'qqq/return-t)
    (let ((res (apply orig-fun args)))
      (advice-remove 'yes-or-no-p #'qqq/return-t)
      (advice-remove 'y-or-n-p #'qqq/return-t)
      res))
  (advice-add 'org-roam-capture--finalize :around #'qqq/disable-yornp))

(use-package org
  :general
  (qqq/local-leader
    org-capture-mode-map
    "c" #'org-capture-finalize
    "k" #'org-capture-kill)
  (general-def '(normal)
    org-mode-map
    "RET" 'org-open-at-point
    "gx"  'org-open-at-point))

(use-package evil-org
  :after (evil org)
  :custom
  (evil-org-key-theme '(navigation insert textobjects additional calendar todo return))
  :hook ((org-mode . evil-org-mode))
  :config
  (require 'evil-org-agenda)
  (evil-org-agenda-set-keys)
  (evil-org-set-key-theme))

(use-package flyspell
  :hook
  (text-mode . flyspell-mode))
