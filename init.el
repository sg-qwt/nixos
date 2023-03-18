(eval-when-compile
  (require 'use-package))

(use-package emacs
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

  :config
  (load custom-file t)
  (savehist-mode 1)
  (recentf-mode 1)

  (menu-bar-mode 0)
  (tool-bar-mode 0)
  (scroll-bar-mode 0)

  (add-hook 'minibuffer-setup-hook #'cursor-intangible-mode)
  (add-hook 'emacs-startup-hook #'(lambda () (find-file (concat user-emacs-directory "init.el")))))

(use-package evil
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

(use-package general
  :after evil
  :config
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
    "h f" #'describe-function)

  (qqq/leader
    "s c" #'evil-ex-nohighlight
    "s b" #'consult-line
    "s p" #'consult-ripgrep
    )

  (qqq/leader
    "b b" #'consult-buffer)

  (qqq/leader
    "f f" #'find-file
    "f d" #'dired)

  (qqq/leader
    "q" #'save-buffers-kill-emacs)

  (qqq/local-leader
    "e b" #'eval-buffer
    "e f" #'eval-defun)

  )

(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles basic partial-completion)))))

(use-package marginalia
  :demand t
  :general
  (general-def
    '(normal insert)
    minibuffer-local-map
    "<escape>" 'abort-minibuffers
    "M-A" 'marginalia-cycle)
  :config
  (marginalia-mode 1))

(use-package vertico
  :demand t
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
   )
  (general-def
    '(normal)
    vertico-map
    "G" 'vertico-last
    "g g" 'vertico-first
    )
  )
