(eval-when-compile
  (require 'use-package))

(when init-file-debug
  (setq use-package-verbose t
	use-package-expand-minimally nil
	use-package-compute-statistics t
	debug-on-error t))

(use-package qqqdefun
  :no-require t
  :preface
  (defun qqq/return-t (orig-fun &rest args) t)

  (defun qqq/disable-yornp (orig-fun &rest args)
    (advice-add 'yes-or-no-p :around #'qqq/return-t)
    (advice-add 'y-or-n-p :around #'qqq/return-t)
    (let ((res (apply orig-fun args)))
      (advice-remove 'yes-or-no-p #'qqq/return-t)
      (advice-remove 'y-or-n-p #'qqq/return-t)
      res))

  (defun qqq/ex-kill-buffer ()
    (interactive)
    (kill-current-buffer))

  (defun qqq/ex-save-kill-buffer-and-close ()
    (interactive)
    (save-buffer)
    (kill-current-buffer))

  (defun qqq/switch-to-message ()
    (interactive)
    (display-buffer "*Messages*"))

  (defun qqq/rename-current-buffer-file ()
    "Renames current buffer and file it is visiting."
    (interactive)
    (let* ((name (buffer-name))
	   (filename (buffer-file-name)))
      (if (not (and filename (file-exists-p filename)))
	  (error "Buffer '%s' is not visiting a file!" name)
	(let* ((dir (file-name-directory filename))
	       (new-name (read-file-name "New name: " dir)))
	  (cond ((get-buffer new-name)
		 (error "A buffer named '%s' already exists!" new-name))
		(t
		 (let ((dir (file-name-directory new-name)))
		   (when (and (not (file-exists-p dir)) (yes-or-no-p (format "Create directory '%s'?" dir)))
		     (make-directory dir t)))
		 (rename-file filename new-name 1)
		 (rename-buffer new-name)
		 (set-visited-file-name new-name)
		 (set-buffer-modified-p nil)
		 (when (fboundp 'recentf-add-file)
		   (recentf-add-file new-name)
		   (recentf-remove-if-non-kept filename))
		 (when (and (configuration-layer/package-usedp 'projectile)
			    (projectile-project-p))
		   (call-interactively #'projectile-invalidate-cache))
		 (message "File '%s' successfully renamed to '%s'" name (file-name-nondirectory new-name)))))))))

(use-package modus-themes
  :custom
  (modus-themes-bold-constructs t)
  :config
  (setq modus-themes-common-palette-overrides modus-themes-preset-overrides-intense)
  (load-theme 'modus-operandi t))

(use-package autorevert
  :custom
  (global-auto-revert-non-file-buffers t)
  (auto-revert-use-notify nil)
  (auto-revert-verbose nil)
  :config
  (global-auto-revert-mode t))

(use-package savehist
  :config
  (savehist-mode 1))

(use-package mb-depth
  :config
  (minibuffer-depth-indicate-mode 1))

(use-package startup
  :preface
  (defun qqq/startup ()
    (with-current-buffer "*scratch*"
      (goto-char (point-max))
      (insert (concat "\n;; Emacs startup time: "
		      (format "%d packages loaded in %s" (length package-activated-list) (emacs-init-time))))))
  :hook
  (emacs-startup . qqq/startup)
  :custom
  (inhibit-startup-screen t)
  (initial-scratch-message (shell-command-to-string "grab-shi"))
  (initial-major-mode 'emacs-lisp-mode))

(use-package emacs
  :init
  (setq qqq/garden-dir (substitute-in-file-name "${HOME}/garden"))
  :custom
  (ring-bell-function #'ignore)
  (custom-file (concat user-emacs-directory "custom.el"))

  (backup-directory-alist `((".*" . ,temporary-file-directory)))

  (auto-save-file-name-transforms `((".*" ,temporary-file-directory t)))

  (auto-save-list-file-prefix (concat temporary-file-directory "auto-saves-list/.saves-"))

  (use-dialog-box nil)

  (enable-recursive-minibuffers t)
  (minibuffer-prompt-properties '(read-only t cursor-intangible t face minibuffer-prompt))

  (use-short-answers t)
  :config
  (load custom-file t) ;; write customizations to a separate file
  (recentf-mode 1)
  (menu-bar-mode 0)
  (tool-bar-mode 0)
  (scroll-bar-mode 0)

  ;;;;;;;;;;
  ;; font ;;
  ;;;;;;;;;;
  (set-face-attribute 'default nil :font "JetBrains Mono 10")
  (dolist (charset '(kana han symbol cjk-misc bopomofo))
    (set-fontset-font (frame-parameter nil 'font) charset
		      (font-spec :family "LXGW WenKai Mono" :size 14))))

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
  (evil-ex-define-cmd "wq" 'qqq/ex-save-kill-buffer-and-close)
  (evil-ex-define-cmd "q" 'qqq/ex-kill-buffer)
  (evil-mode 1))

(use-package evil-surround
  :config
  (global-evil-surround-mode 1))

(use-package evil-collection
  :after (evil magit)
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
    "TAB" #'mode-line-other-buffer
    "SPC" #'execute-extended-command
    "/" #'consult-ripgrep)

  (qqq/leader
    :infix "c"
    "l" #'comment-line
    "b" #'comment-box
    "r" #'comment-or-uncomment-region
    "c" #'comment-dwim)

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
    "t t" #'modus-themes-toggle
    "t p" #'smartparens-mode)

  ;;;;;;;;;;;;
  ;; search ;;
  ;;;;;;;;;;;;
  (qqq/leader
    :infix "s"
    "c" #'evil-ex-nohighlight
    "b" #'consult-line
    "p" #'consult-ripgrep)

  (qqq/leader
    :infix "b"
    "b" #'consult-buffer
    "s" #'scratch-buffer
    "m" #'qqq/switch-to-message
    "p" #'qqq/consult-buffer-p
    "d" #'kill-current-buffer)

  ;;;;;;;;;;
  ;; file ;;
  ;;;;;;;;;;
  (qqq/leader
    :infix "f"
    "r" #'qqq/rename-current-buffer-file
    "f" #'find-file
    "p" #'project-find-file
    "d" #'dired-jump
    "D" #'dired-jump-other-window)

  (qqq/leader
    "q" #'save-buffers-kill-emacs)

  (qqq/local-leader
    with-editor-mode-map
    "c" #'with-editor-finish
    "k" #'with-editor-cancel))

(use-package consult
  :demand t
  :preface
  (defun qqq/consult-buffer-p ()
    (interactive)
    (setq unread-command-events (append unread-command-events (list ?p 32)))
    (consult-buffer))
  :custom
  (consult-narrow-key "<")
  (consult-preview-excluded-files '(".*\\.gpg$")))

(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles basic partial-completion)))))

(use-package magit
  :demand t
  :general
  (qqq/leader
    "g s" #'magit-status)
  (general-def
    '(normal)
    magit-status-mode-map
    "<escape>" #'transient-quit-one))

(use-package marginalia
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
  :general
  (general-def
    '(normal insert)
    vertico-map
    "C-j" 'vertico-next
    "C-k" 'vertico-previous
    "C-l" 'vertico-insert
    "C-p" 'previous-history-element
    "C-n" 'next-history-element 
    "C-w" 'vertico-directory-delete-word
    "C-f" 'vertico-scroll-up
    "C-b" 'vertico-scroll-down
    "C-]" 'top-level
    "C-r" 'consult-history)
  (general-def
    '(normal)
    vertico-map
    "G" 'vertico-last
    "g g" 'vertico-first)
  :hook
  (minibuffer-setup . cursor-intangible-mode)
  :custom
  (vertico-resize t)
  (vertico-cycle t)
  :config
  (vertico-mode 1))

(use-package nix-mode
  :mode "\\.nix\\'")

(use-package hcl-mode
  :mode "\\.tf\\'")

(use-package yaml-ts-mode
  :mode "\\.ya?ml\\'")

(use-package typescript-ts-mode
  :mode "\\.ts\\'")

(use-package org-roam
  :preface
  (defun qqq/orm-capture-p ()
    (interactive)
    (org-roam-capture- :goto nil :keys "p" :node (org-roam-node-create)))
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
  (org-roam-database-connector 'sqlite-builtin)
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

  (require 'org-roam-protocol)
  (add-to-list 'display-buffer-alist
	       '("\\*org-roam\\*"
		 (display-buffer-in-direction)
		 (direction . right)
		 (window-width . 0.33)
		 (window-height . fit-window-to-buffer)))
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
    "gx"  'org-open-at-point)
  :config
  (add-hook 'org-capture-mode-hook
	    (lambda ()
	      (setq-local
	       header-line-format
	       (substitute-command-keys
		"Capture buffer.  Finish \\`, c'.  Abort \\`, k'.")))))

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

(use-package smartparens
  :demand t
  :hook
  ((emacs-lisp-mode)
   . smartparens-strict-mode)
  :config
  (smartparens-global-mode)
  (require 'smartparens-config))

(use-package evil-cleverparens
  :after (evil smartparens)
  :hook
  ((emacs-lisp-mode clojure-mode cider-repl-mode) . evil-cleverparens-mode)
  :config
  (require 'evil-cleverparens-text-objects))

;;;;;;;;;
;; pdf ;;
;;;;;;;;;
(use-package pdf-tools
  :mode ("\\.pdf$" . pdf-view-mode)
  :config
  (pdf-tools-install)
  (add-hook 'pdf-view-mode-hook
	    (lambda ()
	      (set (make-local-variable 'evil-normal-state-cursor) (list nil)))))

;;;;;;;;;;;;
;; nov.el ;;
;;;;;;;;;;;;
(use-package nov
  :mode ("\\.epub$" . nov-mode))

;;;;;;;;;;;;;;;;;;;;;;;;;;
;; display line numbers ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package display-line-numbers
  :config
  (setq display-line-numbers-type 'relative)
  (defcustom display-line-numbers-exempt-modes
    '(nov-mode
      pdf-view-mode)
    "Major modes on which to disable line numbers."
    :group 'display-line-numbers
    :type 'list
    :version "green")
  (defun display-line-numbers--turn-on ()
    "Turn on line numbers except for certain modes.
  Exempt major modes are defined in `display-line-numbers-exempt-modes'."
    (unless (or (minibufferp)
                (member major-mode display-line-numbers-exempt-modes))
      (display-line-numbers-mode)))
  (global-display-line-numbers-mode))


;;;;;;;;;;;;
;; embark ;;
;;;;;;;;;;;;
(use-package embark
  :preface
  (defun qqq/embark-export-write ()
    "Export the current vertico results to a writable buffer if possible.
Supports exporting consult-grep to wgrep, file to wdeired, and consult-location to occur-edit"
    (interactive)
    (require 'embark)
    (require 'wgrep)
    (let* ((edit-command
	    (pcase-let ((`(,type . ,candidates)
			 (run-hook-with-args-until-success 'embark-candidate-collectors)))
	      (pcase type
		('consult-grep #'wgrep-change-to-wgrep-mode)
		('file #'wdired-change-to-wdired-mode)
		('consult-location #'occur-edit-mode))))
	   (embark-after-export-hook `(,@embark-after-export-hook ,edit-command)))
      (embark-export)))
  (defun qqq/exec-with-prefix (target)
    "Execute command with prefix."
    (interactive
     (list (read-string "Read target command ")))
    (let ((prefix (read-from-minibuffer "Execute with prefix: ")))
      (execute-extended-command prefix target)))
  (defun qqq/sdcv-at-word ()
    "Search word under cursor with sdcv"
    (interactive)
    (with-output-to-temp-buffer "*dict*"
      (shell-command  (concat "sdcv --non-interactive " (current-word))
		      "*dict*"
		      "*Messages*")
      (when (get-buffer "*dict*")
	(pop-to-buffer "*dict*")
	(with-current-buffer "*dict*"
	  (ansi-color-apply-on-region (point-min) (point-max))
	  (special-mode)))))
  (defun qqq/sdcv-at-char ()
    "Search character under cursor with sdcv"
    (interactive)
    (with-output-to-temp-buffer "*dict*"
      (shell-command  (concat "sdcv --non-interactive " (string (following-char)))
		      "*dict*"
		      "*Messages*")
      (when (get-buffer "*dict*")
	(pop-to-buffer "*dict*")
	(with-current-buffer "*dict*"
	  (ansi-color-apply-on-region (point-min) (point-max))
	  (special-mode)))))
  :general
  (general-def 'override
    "C-a" 'embark-act
    "C-q" 'embark-dwim)
  (general-def
    '(normal insert)
    minibuffer-local-map
    "C-e" 'qqq/embark-export-write)
  (general-def embark-command-map "x" #'qqq/exec-with-prefix)
  (general-def embark-symbol-map
    "d" #'qqq/sdcv-at-char
    "D" #'qqq/sdcv-at-word)
  (general-def embark-identifier-map
    "d" #'qqq/sdcv-at-char
    "D" #'qqq/sdcv-at-word)

  :init
  (setq prefix-help-command #'embark-prefix-help-command)
  :custom
  (embark-quit-after-action t)
  :config
  ;; hide the mode line of the Embark live/completions buffers
  (add-to-list 'display-buffer-alist
               '("\\`\\*Embark Collect \\(Live\\|Completions\\)\\*"
                 nil
                 (window-parameters (mode-line-format . none)))))

(use-package embark-consult
  :hook
  (embark-collect-mode . consult-preview-at-point-mode))

;;;;;;;;;;;
;; wgrep ;;
;;;;;;;;;;;
(use-package wgrep
  :custom
  (wgrep-auto-save-buffer t))

;;;;;;;;;;;
;; corfu ;;
;;;;;;;;;;;
(use-package corfu
  :demand t
  :general
  (general-def
    '(insert)
    corfu-map
    "C-l" 'corfu-complete
    "C-m" 'corfu-move-to-minibuffer)
  :custom
  (corfu-auto t)
  (corfu-cycle t)
  (corfu-auto-delay 0)
  (corfu-on-exact-match 'quit)
  (tab-always-indent 'complete)
  :preface
  (defun corfu-move-to-minibuffer ()
    (interactive)
    (let ((completion-extra-properties corfu--extra)
	  completion-cycle-threshold completion-cycling)
      (apply #'consult-completion-in-region completion-in-region--data)))
  :init
  (global-corfu-mode))

;;;;;;;;;;;;;;
;; nftables ;;
;;;;;;;;;;;;;;
(use-package nftables-mode
  :mode "\\.nft\\'")

;;;;;;;;;;;;;
;; clojure ;;
;;;;;;;;;;;;;
(use-package clojure-mode
  :config
  (require 'clojure-mode-extra-font-locking))

(use-package cider
  :preface
  (defun qqq/cider-connect-bb ()
    (interactive)
    (cider-connect '(:host "localhost" :port 1667)))

  ;; from spacemacs
  (defun qqq//cider-eval-in-repl-no-focus (form)
    "Insert FORM in the REPL buffer and eval it."
    (while (string-match "\\`[ \t\n\r]+\\|[ \t\n\r]+\\'" form)
      (setq form (replace-match "" t t form)))
    (with-current-buffer (cider-current-connection)
      (let ((pt-max (point-max)))
	(goto-char pt-max)
	(insert form)
	(indent-region pt-max (point))
	(cider-repl-return)
	(with-selected-window (get-buffer-window (cider-current-connection))
	  (goto-char (point-max))))))

  (defun qqq/cider-send-region-to-repl (start end)
    "Send region to REPL and evaluate it without changing
the focus."
    (interactive "r")
    (qqq//cider-eval-in-repl-no-focus
     (buffer-substring-no-properties start end)))

  (defun qqq/cider-send-region-to-repl-focus (start end)
    "Send region to REPL and evaluate it and switch to the REPL in
`insert state'."
    (interactive "r")
    (cider-insert-in-repl
     (buffer-substring-no-properties start end) t)
    (evil-insert-state))

  (defun qqq/cider-send-function-to-repl ()
    "Send current function to REPL and evaluate it without changing
the focus."
    (interactive)
    (qqq//cider-eval-in-repl-no-focus (cider-defun-at-point)))

  (defun qqq/cider-send-function-to-repl-focus ()
    "Send current function to REPL and evaluate it and switch to the REPL in
`insert state'."
    (interactive)
    (cider-insert-defun-in-repl t)
    (evil-insert-state))

  (defun qqq/cider-send-ns-form-to-repl ()
    "Send buffer's ns form to REPL and evaluate it without changing
the focus."
    (interactive)
    (qqq//cider-eval-in-repl-no-focus (cider-ns-form)))

  (defun qqq/cider-send-ns-form-to-repl-focus ()
    "Send ns form to REPL and evaluate it and switch to the REPL in
`insert state'."
    (interactive)
    (cider-insert-ns-form-in-repl t)
    (evil-insert-state))

  (defun qqq/cider-switch ()
    (interactive)
    (if (eq major-mode 'cider-repl-mode)
	(cider-switch-to-last-clojure-buffer)
      (cider-switch-to-repl-buffer)))

  :hook (clojure-mode . cider-mode)

  :general
  (general-unbind cider-repl-mode-map ",")
  (general-def
    '(normal insert)
    cider-repl-mode-map
    "C-l" #'cider-repl-clear-buffer)

  (qqq/local-leader
    clojure-mode-map
    :infix "e"
    "b" #'cider-eval-buffer
    "r" #'cider-eval-region
    "(" #'cider-eval-list-at-point
    "f" #'cider-eval-defun-at-point
    ";" #'cider-eval-defun-to-comment
    "i" #'cider-interrupt
    "m" #'cider-macroexpand-1
    "M" #'cider-macroexpand-all)

  (qqq/local-leader
    :keymaps '(clojure-mode-map cider-repl-mode-map)
    :infix "s"
    "a" #'qqq/cider-switch)

  (qqq/local-leader
    clojure-mode-map
    :infix "s"
    "b" #'cider-load-buffer
    "n" #'qqq/cider-send-ns-form-to-repl
    "N" #'qqq/cider-send-ns-form-to-repl-focus
    "f" #'qqq/cider-send-function-to-repl
    "F" #'qqq/cider-send-function-to-repl-focus
    "r" #'qqq/cider-send-region-to-repl
    "R" #'qqq/cider-send-region-to-repl-focus)

  (qqq/local-leader
    clojure-mode-map
    :infix "h"
    "n" #'cider-find-ns
    "a" #'cider-apropos
    "c" #'cider-clojuredocs
    "d" #'cider-doc
    "j" #'cider-javadoc
    "w" #'cider-clojuredocs-web)

  (qqq/local-leader
    :keymaps '(clojure-mode-map cider-repl-mode-map)
    :infix "c"
    "c" #'cider-connect-clj
    "b" #'qqq/cider-connect-bb
    "r" #'cider-restart
    "q" #'cider-quit)

  (qqq/local-leader
    clojure-mode-map
    :infix "="
    "=" #'cider-format-buffer
    "f" #'cider-format-defun
    "r" #'cider-format-region
    "e b" #'cider-format-edn-buffer))

(use-package cider-eval-sexp-fu :after cider)

;;;;;;;;;;;
;; elisp ;;
;;;;;;;;;;;
(use-package emacs-lisp-mode
  :general
  (qqq/local-leader
    emacs-lisp-mode-map
    :infix "e"
    "b" #'eval-buffer
    "f" #'eval-defun
    "r" #'eval-region
    "e" #'eval-expression
    ";" #'eval-print-last-sexp))

;;;;;;;;;;;
;; dired ;;
;;;;;;;;;;;
(use-package dired
  :custom
  (dired-clean-confirm-killing-deleted-buffers nil)
  (dired-kill-when-opening-new-dired-buffer t)
  (dired-listing-switches "-alh")
  (dired-recursive-copies 'always)
  :config
  (defadvice dired-mark-read-file-name
      (after rv:dired-create-dir-when-needed
	     (prompt dir op-symbol arg files &optional default) activate)
    (when (member op-symbol '(copy move))
      (let ((directory-name (if (< 1 (length files))
				ad-return-value
			      (file-name-directory ad-return-value))))
	(when (and (not (file-directory-p directory-name))
		   (y-or-n-p (format "directory %s doesn't exist, create it?" directory-name)))
	  (make-directory directory-name t))))))

(use-package peep-dired
  :custom
  (peep-dired-cleanup-on-disable t)
  :general
  (general-def dired-mode-map
    [remap dired-do-print] 'peep-dired)
  (general-def
    '(normal)
    peep-dired-mode-map
    "j" #'peep-dired-next-file
    "k" #'peep-dired-prev-file))

;;;;;;;;;;;
;; eglot ;;
;;;;;;;;;;;
(use-package eglot
  ;; :custom
  ;; :documentHighlightProvider
  ;; (eglot-ignored-server-capabilities '(:hoverProvider))
  ;; :init
  ;; (setq eglot-stay-out-of '(yasnippet corfu))
  :hook
  ((nix-mode . eglot-ensure))
  :config
  (add-to-list 'eglot-server-programs '((nix-mode) "nil")))

(use-package eldoc
  :custom
  (eldoc-documentation-strategy 'eldoc-documentation-compose-eagerly)
  (eldoc-echo-area-use-multiline-p nil)
  (eldoc-echo-area-prefer-doc-buffer t))

;;;;;;;;;;;;;;;;;;;;;;
;; cape & yasnippet ;;
;;;;;;;;;;;;;;;;;;;;;;
(use-package yasnippet
  :demand t
  :general
  (general-unbind yas-minor-mode-map
    "TAB"
    "<tab>")
  :custom
  (yas-snippet-dirs `(,(concat user-emacs-directory "snippets")))
  :config
  (yas-global-mode 1))

(use-package cape
  :init
  (add-to-list 'completion-at-point-functions #'cape-dabbrev)
  (add-to-list 'completion-at-point-functions #'cape-file))

(use-package cape-yasnippet
  :after (cape yasnippet)
  :init
  (add-to-list 'completion-at-point-functions #'cape-yasnippet))

(use-package eglot-cape
  :no-require t
  :after (cape eglot)
  :hook (eglot-managed-mode . qqq/eglot-capf)
  :preface
  (defun qqq/eglot-capf ()
    (setq-local completion-at-point-functions
		(list (cape-super-capf
		       (cape-capf-buster #'eglot-completion-at-point)
		       #'cape-yasnippet
		       #'cape-file)))))

(use-package elisp-mode-cape
  :no-require t
  :after (cape elisp-mode)
  :hook (emacs-lisp-mode . qqq/setup-elisp)
  :preface
  (defun qqq/setup-elisp ()
    (setq-local completion-at-point-functions
		(list (cape-super-capf
		       #'elisp-completion-at-point
		       #'cape-dabbrev)
		      #'cape-file))))
