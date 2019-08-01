
;; init

;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.
(package-initialize)
(add-to-list 'load-path "~/.emacs.d/smex")
(add-to-list 'load-path "~/.emacs.d/ergoemacs-mode")
;;(add-to-list 'load-path "~/.emacs.d/d/go-mode.el")
;;(add-to-list 'auto-mode-alist '("\\.go\\'" . go-mode))
(require 'package)
(package-initialize)
(add-to-list 'package-archives '("melpa" . "http://melpa.milkbox.net/packages/") t)
(require 'smex)
(require 'linum)
(require 'go-autocomplete)
(require 'auto-complete-config)
(ac-config-default)
(require 'ergoemacs-mode)
(setq frame-title-format "Emacs")
(setq ergoemacs-keyboard-layout "us")
(setq-default indent-tabs-mode 1)
(setq-default tab-width        4)
;;(autoload 'go-mode "go-mode" nil t )
(ergoemacs-mode 1)
(menu-bar-mode -1)
(tool-bar-mode -1)
(line-number-mode 1)
(global-linum-mode 1)
(scroll-bar-mode -1)
(set-default 'cursor-type 'hbar)
(column-number-mode)
(fset 'yes-or-no-p 'y-or-n-p)
(ido-mode)
(setq-default gofmt-command "goimports")
(setq inhibit-splash-screen t)
(setq ingibit-startup-message t)
(add-hook 'sgml-mode-hook 'emmet-mode) ;; Auto-start on any markup modes
(add-hook 'css-mode-hook  'emmet-mode) ;; enable Emmet's css abbreviation.
(add-hook 'python-mode-hook 'jedi:setup)    ;; enable jedi
(add-hook 'python-mode-hook 'jedi:ac-setup) ;; enable ac-setup
(add-hook 'before-save-hook 'gofmt-before-save)
(add-hook 'completion-at-point-functions 'go-complete-at-point)
(defun auto-complete-for-go ()
  (auto-complete-mode 1))
(add-hook 'go-mode-hook 'auto-complete-for-go)
;; Key bindings


;;;;; FUCK THIS SHIT OVER
;;;;;
;;;;;
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   (quote
	(rust-mode go-autocomplete go-complete go-mode auto-correct yasnippet jedi 2048-game pacmacs emmet-mode nord-theme))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
;;;;;
;;;;;
;;;;;

										
										