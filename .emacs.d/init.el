;; init

;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.
(package-initialize)
(add-to-list 'load-path "~/.emacs.d/smex")
(add-to-list 'load-path "~/.emacs.d/vendor/emacs-powerline")
;;(add-to-list 'load-path "~/.emacs.d/ergoemacs-mode")
(require 'package)
(load-theme 'doom-city-lights t)
(package-initialize)
;;(package-refresh-contents)
(add-to-list 'package-archives '("MARMALADE" . "http://marmalade-repo.org/packages/"))
(add-to-list 'package-archives '("MELPA STABLE" . "http://stable.melpa.org/packages/"))
(add-to-list 'package-archives '("melpa" . "http://melpa.milkbox.net/packages/") t)
(add-to-list 'default-frame-alist '(font . "Input Mono Condensed-10"))
(require 'linum)
(require 'go-autocomplete)
(require 'all-the-icons)
(require 'auto-complete-config)
(defun set-buffer-font (font size)
  (interactive "sFont: \nnSize: ")
  "Sets the specified font in current buffer"
  (setq buffer-face-mode-face `(:family ,font :height ,(* size 10)))
  (buffer-face-mode))

(setq frame-title-format '(buffer-file-name "%f" ("%b")))
(setq-default indent-tab-mode 1)
(setq-default tab-width        4)
(setq doom-modeline-height 25)
(setq doom-modeline-bar-width 3)
(defconst animate-n-step 3)

(defun emacs-reloaded()
  (sleep-for 1)
  (animate-string (concat ";; Welcome to EMACS, " user-login-name ".") 0 0)
  (newline-and-indent) (newline-and-indent))

;;(use-package electric)

(use-package projectile
  :ensure t
  :init
  (setq projectile-completion-system 'ivy)
  :config
  (projectile-mode +1))
(use-package doom-modeline
  :ensure t
  :hook (after-init . doom-modeline-mode))

(use-package neotree
  :bind ([f8] . neotree-toggle)
  :init (setq neo-window-width 25)
  :config (setq neo-smart-open nil))

(use-package dashboard
  :ensure t
  :config
  (dashboard-setup-startup-hook)
  (setq dashboard-banner-logo-title (concat "Welcome to EMACS, " user-login-name))
  (setq dashboard-startup-banner 'logo)
  )

(use-package all-the-icons)
(use-package flymd)
(use-package smex
  :config (smex-initialize)
  :bind ("M-x" . smex)
  ("M-X" . smex-major-mode-commands)
  ("C-c M-x" . execute-extended-command))

(defun my-flymd-browser-function (url)
  (let ((process-environment (browse-url-process-environment)))
    (apply 'start-process
           (concat "firefox " url)
           nil
           "/usr/bin/open"
           (list "-a" "firefox" url))))
(setq flymd-browser-open-function 'my-flymd-browser-function)

(use-package markdown-mode
  :ensure t
  :commands (markdown-mode gfm-mode)
  :mode (("README\\.md\\'" . gfm-mode)
         ("\\.md\\'" . markdown-mode)
         ("\\.markdown\\'" . markdown-mode))
  :init (setq markdown-command "multimarkdown"))

;;(use-package powerline
;;  :init
;;  (powerline-default-theme))
;;  (add-hook 'after-init-hook 'powerline-reset)

(use-package emmet-mode
  :config (add-hook 'sgml-mode-hook 'emmet-mode)
  (add-hook 'css-mode-hook 'emmet-mode))

(use-package tramp-mode
  :defer t
  :config
  (setf tramp-persistency-file-name
		(concat temporary-file-directory "tramp-" (user-login-name))))

(use-package jedi
  :ensure t
  :init
  (add-hook 'python-mode-hook 'jedi:setup)
  (add-hook 'python-mode-hook 'jedi:ac-setup)
  (setq jedi:complete-on-dot t)
  (setq jedi:setup-keys t))

(use-package auto-complete
  :diminish auto-complete-mode
  :config (ac-config-default))

(use-package go-mode
  :ensure t
  :hook (go-mode . ( lambda () (my/set-buffer-font "Fira Code")))
  :init
  (progn
	(setq gofmt-command "goimports")
	(add-hook 'before-save-hook 'gofmt-before-save))
  :config
  (add-hook 'go-mode-hook 'electric-pair-mode))
(use-package em-term
  :custom
  ;; Visual commands are commands which require a proper terminal
  ;; eshell will run them in a term buffer when you invoke them.
  (eshell-visual-commands
   '("tmux" "htop" "top"))
  (eshell-visual-subcommands
   '(("git" "log" "l" "diff" "show"))))

(menu-bar-mode -1)
(tool-bar-mode -1)
(line-number-mode 1)
(global-linum-mode 1)
(scroll-bar-mode -1)
(set-default 'cursor-type 'hbar)
(column-number-mode)
(fset 'yes-or-no-p 'y-or-n-p)
(ido-mode)
(setq inhibit-splash-screen t)
(setq ingibit-startup-message t)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   (quote
	("41c8c11f649ba2832347fe16fe85cf66dafe5213ff4d659182e25378f9cfc183" "fa2b58bb98b62c3b8cf3b6f02f058ef7827a8e497125de0254f56e373abee088" "bffa9739ce0752a37d9b1eee78fc00ba159748f50dc328af4be661484848e476" "a0feb1322de9e26a4d209d1cfa236deaf64662bb604fa513cca6a057ddf0ef64" "04dd0236a367865e591927a3810f178e8d33c372ad5bfef48b5ce90d4b476481" "7153b82e50b6f7452b4519097f880d968a6eaf6f6ef38cc45a144958e553fbc6" "1068ae7acf99967cc322831589497fee6fb430490147ca12ca7dd3e38d9b552a" "7356632cebc6a11a87bc5fcffaa49bae528026a78637acd03cae57c091afd9b9" "59e82a683db7129c0142b4b5a35dbbeaf8e01a4b81588f8c163bd255b76f4d21" default)))
 '(package-selected-packages
   (quote
	(use-package darcula-theme neotree lua-mode cyberpunk-2019-theme powerline-evil zerodark-theme alect-themes cyberpunk-theme rust-mode go-autocomplete go-complete go-mode auto-correct yasnippet jedi 2048-game pacmacs emmet-mode nord-theme))))
								 
(use-package cus-edit
  :custom
  (custom-file null-device "Don't store customizations"))


(add-hook 'after-init-hook 'emacs-reloaded)
