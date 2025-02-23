
;;(add-hook 'after-init-hook 'emacs-reloaded)
;;
(require 'package)
(add-to-list 'package-archives '("melpa-stable" . "https://stable.melpa.org/packages/") t)
(add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/") t)


;;
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name
        "straight/repos/straight.el/bootstrap.el"
        (or (bound-and-true-p straight-base-dir)
            user-emacs-directory)))
      (bootstrap-version 7))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

(straight-use-package 'use-package)
(use-package emmet-mode
  :ensure t
  :hook (
	 (css-mode-hook . emmet-mode)
	 (html-mode-hook . emmet-mode)))

(use-package go-mode
  :ensure t)


(use-package eglot
  :hook
  ((go-mode-hook . 'eglot-ensure)))


(use-package yasnippet
  :ensure t
  :config
  (setq
   yas-verbosity 1
   yas-wrap-around-region t)
  (with-eval-after-load 'yasnippet
    (setq yas-snippet-dirs '(yasnippet-snippets-dir)))
  (yas-reload-all)
  (yas-global-mode 1))

(use-package yasnippet-snippets         ; Collection of snippets
:ensure t)

(use-package company
  :ensure t
  :config
  (setq company-idle-delay 0)
  (setq company-minimum-prefix-length 1)
  (add-to-list
   'company-backends '(company-capf company-yasnippet))
  :hook (
	 (after-init-hook . global-company-mode)))

(use-package company-quickhelp;
  :ensure t
  :hook (company-mode  . company-quickhelp-mode))
(use-package vertico
  :ensure t
  :init
  (vertico-mode))
(use-package consult
  :ensure t)
(use-package savehist
  :init
  (savehist-mode))

(use-package projectile
  :ensure t
  :init
  (projectile-mode +1)
  :bind (:map projectile-mode-map
              ("s-p" . projectile-command-map)
              ("C-c p" . projectile-command-map)))

(if (version< emacs-version "30.0")
    (use-package which-key ;; which-key included in Emacs 30
      :ensure t))


(use-package dashboard
  :ensure t
  :config
  (dashboard-setup-startup-hook))

(use-package ayu-theme
  :ensure t
  :config (load-theme 'ayu-dark t))
(use-package neotree
  :ensure t
  :config
  (global-set-key [f8] 'neotree-toggle))
(use-package tramp
  :ensure nil
  :config
  (connection-local-set-profile-variables 'remote-path-mylinux

					  '((tramp-remote-path . ("*/bin" "/usr/local/bin" tramp-default-remote-path))))

  (connection-local-set-profiles
   '(:application tramp :machine "mylinux") 'remote-path-mylinux)


  )


(load (file-name-concat user-emacs-directory "config.el"))
