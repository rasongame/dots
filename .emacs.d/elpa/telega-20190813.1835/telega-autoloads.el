;;; telega-autoloads.el --- automatically extracted autoloads
;;
;;; Code:

(add-to-list 'load-path (directory-file-name
                         (or (file-name-directory #$) (car load-path))))


;;;### (autoloads nil "telega" "telega.el" (0 0 0 0))
;;; Generated autoloads from telega.el

(autoload 'telega "telega" "\
Start telegramming.
If prefix ARG is given, then will not pop to telega root buffer.

\(fn ARG)" t nil)

(autoload 'telega-kill "telega" "\
Kill currently running telega.
With prefix arg FORCE quit without confirmation.

\(fn FORCE)" t nil)

(if (fboundp 'register-definition-prefixes) (register-definition-prefixes "telega" '("telega-")))

;;;***

;;;### (autoloads nil "telega-chat" "telega-chat.el" (0 0 0 0))
;;; Generated autoloads from telega-chat.el

(if (fboundp 'register-definition-prefixes) (register-definition-prefixes "telega-chat" '("telega-" "with-telega-chatbuf-action")))

;;;***

;;;### (autoloads nil "telega-company" "telega-company.el" (0 0 0
;;;;;;  0))
;;; Generated autoloads from telega-company.el

(autoload 'telega-company-emoji "telega-company" "\
Backend for `company' to complete emojis.

\(fn COMMAND &optional ARG &rest IGNORED)" t nil)

(autoload 'telega-company-username "telega-company" "\
Backend for `company' to complete usernames.

\(fn COMMAND &optional ARG &rest IGNORED)" t nil)

(autoload 'telega-company-botcmd "telega-company" "\


\(fn COMMAND &optional ARG &rest IGNORED)" t nil)

(if (fboundp 'register-definition-prefixes) (register-definition-prefixes "telega-company" '("telega-company-")))

;;;***

;;;### (autoloads nil "telega-core" "telega-core.el" (0 0 0 0))
;;; Generated autoloads from telega-core.el

(if (fboundp 'register-definition-prefixes) (register-definition-prefixes "telega-core" '("telega-" "with-telega-")))

;;;***

;;;### (autoloads nil "telega-customize" "telega-customize.el" (0
;;;;;;  0 0 0))
;;; Generated autoloads from telega-customize.el

(if (fboundp 'register-definition-prefixes) (register-definition-prefixes "telega-customize" '("telega-")))

;;;***

;;;### (autoloads nil "telega-ffplay" "telega-ffplay.el" (0 0 0 0))
;;; Generated autoloads from telega-ffplay.el

(if (fboundp 'register-definition-prefixes) (register-definition-prefixes "telega-ffplay" '("telega-ffplay-")))

;;;***

;;;### (autoloads nil "telega-filter" "telega-filter.el" (0 0 0 0))
;;; Generated autoloads from telega-filter.el

(if (fboundp 'register-definition-prefixes) (register-definition-prefixes "telega-filter" '("label" "type" "top" "telega-" "saved-messages" "custom" "contact" "restriction" "opened" "has-" "mention" "me-is-member" "ids" "verified" "unread" "user-status" "name" "not" "pin" "any" "all" "define-telega-filter")))

;;;***

;;;### (autoloads nil "telega-i18n" "telega-i18n.el" (0 0 0 0))
;;; Generated autoloads from telega-i18n.el

(if (fboundp 'register-definition-prefixes) (register-definition-prefixes "telega-i18n" '("telega-")))

;;;***

;;;### (autoloads nil "telega-info" "telega-info.el" (0 0 0 0))
;;; Generated autoloads from telega-info.el

(if (fboundp 'register-definition-prefixes) (register-definition-prefixes "telega-info" '("telega-")))

;;;***

;;;### (autoloads nil "telega-inline" "telega-inline.el" (0 0 0 0))
;;; Generated autoloads from telega-inline.el

(if (fboundp 'register-definition-prefixes) (register-definition-prefixes "telega-inline" '("telega-")))

;;;***

;;;### (autoloads nil "telega-ins" "telega-ins.el" (0 0 0 0))
;;; Generated autoloads from telega-ins.el

(if (fboundp 'register-definition-prefixes) (register-definition-prefixes "telega-ins" '("telega-")))

;;;***

;;;### (autoloads nil "telega-media" "telega-media.el" (0 0 0 0))
;;; Generated autoloads from telega-media.el

(autoload 'telega-media-auto-download-mode "telega-media" "\
Toggle automatic media download for incoming messages.
With positive ARG - enables automatic downloads, otherwise disables.
To customize automatic downloads, use `telega-auto-download'.

\(fn &optional ARG)" t nil)

(if (fboundp 'register-definition-prefixes) (register-definition-prefixes "telega-media" '("telega-")))

;;;***

;;;### (autoloads nil "telega-msg" "telega-msg.el" (0 0 0 0))
;;; Generated autoloads from telega-msg.el

(if (fboundp 'register-definition-prefixes) (register-definition-prefixes "telega-msg" '("telega-")))

;;;***

;;;### (autoloads nil "telega-notifications" "telega-notifications.el"
;;;;;;  (0 0 0 0))
;;; Generated autoloads from telega-notifications.el

(autoload 'telega-notifications-mode "telega-notifications" "\
Toggle telega notifications on or off.
With positive ARG - enables notifications, otherwise disables.
If ARG is not given then treat it as 1.

\(fn &optional ARG)" t nil)

(if (fboundp 'register-definition-prefixes) (register-definition-prefixes "telega-notifications" '("telega-")))

;;;***

;;;### (autoloads nil "telega-root" "telega-root.el" (0 0 0 0))
;;; Generated autoloads from telega-root.el

(if (fboundp 'register-definition-prefixes) (register-definition-prefixes "telega-root" '("telega-")))

;;;***

;;;### (autoloads nil "telega-server" "telega-server.el" (0 0 0 0))
;;; Generated autoloads from telega-server.el

(if (fboundp 'register-definition-prefixes) (register-definition-prefixes "telega-server" '("telega-" "with-telega-deferred-events")))

;;;***

;;;### (autoloads nil "telega-sticker" "telega-sticker.el" (0 0 0
;;;;;;  0))
;;; Generated autoloads from telega-sticker.el

(if (fboundp 'register-definition-prefixes) (register-definition-prefixes "telega-sticker" '("telega-")))

;;;***

;;;### (autoloads nil "telega-tme" "telega-tme.el" (0 0 0 0))
;;; Generated autoloads from telega-tme.el

(if (fboundp 'register-definition-prefixes) (register-definition-prefixes "telega-tme" '("telega-tme-")))

;;;***

;;;### (autoloads nil "telega-user" "telega-user.el" (0 0 0 0))
;;; Generated autoloads from telega-user.el

(if (fboundp 'register-definition-prefixes) (register-definition-prefixes "telega-user" '("telega-")))

;;;***

;;;### (autoloads nil "telega-util" "telega-util.el" (0 0 0 0))
;;; Generated autoloads from telega-util.el

(if (fboundp 'register-definition-prefixes) (register-definition-prefixes "telega-util" '("telega-")))

;;;***

;;;### (autoloads nil "telega-voip" "telega-voip.el" (0 0 0 0))
;;; Generated autoloads from telega-voip.el

(if (fboundp 'register-definition-prefixes) (register-definition-prefixes "telega-voip" '("telega-")))

;;;***

;;;### (autoloads nil "telega-vvnote" "telega-vvnote.el" (0 0 0 0))
;;; Generated autoloads from telega-vvnote.el

(if (fboundp 'register-definition-prefixes) (register-definition-prefixes "telega-vvnote" '("telega-vvnote-")))

;;;***

;;;### (autoloads nil "telega-webpage" "telega-webpage.el" (0 0 0
;;;;;;  0))
;;; Generated autoloads from telega-webpage.el

(if (fboundp 'register-definition-prefixes) (register-definition-prefixes "telega-webpage" '("telega-")))

;;;***

;;;### (autoloads nil nil ("telega-pkg.el") (0 0 0 0))

;;;***

;; Local Variables:
;; version-control: never
;; no-byte-compile: t
;; no-update-autoloads: t
;; coding: utf-8
;; End:
;;; telega-autoloads.el ends here
