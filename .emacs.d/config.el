(set-frame-font "Cascadia Code 11" nil t)
(if (eq system-type 'darwin) ; if macos then use Monaco font else Cascadia Code :)
    (set-frame-font "Monaco 11" nil t))
;;;

(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(column-number-mode)
(add-hook 'prog-mode-hook #'display-line-numbers-mode)
(which-key-mode)
;;(global-hl-line-mode)
(electric-pair-mode)
;;;
(set-default 'cursor-type 'hbar)
(fset 'yes-or-no-p 'y-or-n-p)
;;;

(add-to-list 'default-frame-alist '(fullscreen . maximized)) ;; ebaniy emacs otkrivaysya v fullscreene
(setq frame-title-format (format "Visual Studio Code 🍺 at %s - %%b" (system-name)))
(setq visible-bell 'vb)
;;(setq ring-bell-function 'ignore)

