(set-frame-font "Cascadia Code 11" nil t)
(if (eq system-type 'darwin) ; if macos then use Monaco font else Cascadia Code :)
    (set-frame-font "Monaco 11" nil t))
;;;

(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(column-number-mode)
(add-hook 'prog-mode-hook #'display-line-numbers-mode)
(add-hook 'yaml-mode #'display-line-numbers-mode)
(which-key-mode)
(electric-pair-mode)
;;;
(set-default 'cursor-type 'hbar)
(fset 'yes-or-no-p 'y-or-n-p)
;;;

(add-to-list 'default-frame-alist '(fullscreen . maximized)) ;; ebaniy emacs otkrivaysya v fullscreene
(setq frame-title-format (format "Vim 🍺 at %s - %%b" (system-name)))
(setq visible-bell 'vb)
;;(setq ring-bell-function 'ignore)

(defun my-command-error-function (data context caller)
  "Ignore the buffer-read-only, beginning-of-buffer,
end-of-buffer signals; pass the rest to the default handler."
  (when (not (memq (car data) '(buffer-read-only
                                beginning-of-buffer
                                end-of-buffer)))
    (command-error-default-function data context caller)))

(setq command-error-function #'my-command-error-function)



