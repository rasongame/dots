;;; telega-root.el --- Root buffer for telega  -*- lexical-binding:t -*-

;; Copyright (C) 2018-2019 by Zajcev Evgeny.

;; Author: Zajcev Evgeny <zevlg@yandex.ru>
;; Created: Sat Apr 14 15:00:27 2018
;; Keywords:

;; telega is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; telega is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with telega.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;;

;;; Code:
(require 'ewoc)
(require 'telega-core)
(require 'telega-util)
(require 'telega-server)
(require 'telega-filter)
(require 'telega-info)
(require 'telega-voip)
(require 'telega-ins)
(require 'telega-customize)

(declare-function tracking-mode "tracking" (&optional arg))

(declare-function telega-chats--kill-em-all "telega-chat")
(declare-function telega-chat-title "telega-chat" (chat &optional with-username))
(declare-function telega-chat-get "telega-chat" (chat-id &optional offline-p))
(declare-function telega--searchPublicChats "telega-chat" (query &optional callback))
(declare-function telega-chat--info "telega-chat" (chat))
(declare-function telega--searchChats "telega-chat" (query &optional limit))


(defvar telega-root--ewoc nil)
(defvar telega-contacts--ewoc nil
  "Ewoc for contacts list.")
(defvar telega-search--ewoc nil
  "Ewoc for global chats searched.")
(defvar telega-messages--ewoc nil
  "Ewoc for searched messages.")

(defvar telega-status--timer nil
  "Timer used to animate status string.")
(defvar telega-search--timer nil
  "Timer used to animate Loading.. status of global/messages search.")

(defvar telega-root-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map [remap self-insert-command] 'ignore)
    (define-key map "n" 'telega-button-forward)
    (define-key map "p" 'telega-button-backward)
    (define-key map [?\t] 'telega-button-forward)
    (define-key map "\e\t" 'telega-button-backward)
    (define-key map [backtab] 'telega-button-backward)

    (define-key map (kbd "/") telega-filter-map)
    (define-key map (kbd "C-/") 'telega-filter-undo)
    (define-key map (kbd "C-_") 'telega-filter-undo)
    (define-key map (kbd "C-x C-/") 'telega-filter-redo)
    (define-key map (kbd "C-x C-_") 'telega-filter-redo)

    (define-key map (kbd "? w") 'telega-describe-connected-websites)
    (define-key map (kbd "? s") 'telega-describe-active-sessions)
    (define-key map (kbd "? n") 'telega-describe-network)
    (define-key map (kbd "? y") 'telega-describe-notifications)
    (define-key map (kbd "? N") 'telega-describe-notifications)
    (define-key map (kbd "? p") 'telega-describe-privacy-settings)

    (define-key map (kbd "J") 'telega-chat-join-by-link)
    (define-key map (kbd "N") 'telega-chat-create)
    ;; Commands to all currently filtered chats

    ;; NOTE: Deleting all chats is very-very-very dangerous, so
    ;; disabled, use M-x telega-chats-filtered-delete RET if you know
    ;; what you are doing
    ;; (define-key map (kbd "D") 'telega-chats-filtered-delete)
    (define-key map (kbd "R") 'telega-chats-filtered-toggle-read)

    ;; Calls bindings
    (define-key map (kbd "c a") 'telega-voip-accept)
    (define-key map (kbd "c d") 'telega-voip-discard)
    (define-key map (kbd "c b") 'telega-voip-buffer-show)
    (define-key map (kbd "c l") 'telega-voip-list-calls)

    (define-key map (kbd "s") 'telega-search)
    (define-key map (kbd "q") 'bury-buffer)
    (define-key map (kbd "Q") 'telega-kill)

    (define-key map (kbd "m") 'telega-chat-with)
    map)
  "The key map for telega root buffer.")

(define-derived-mode telega-root-mode nil "Telega-Root"
  "The mode for telega root buffer.

Chat bindings (cursor on chat):
\\{telega-chat-button-map}
Global root bindings:
\\{telega-root-mode-map}"
  :group 'telega-root
  (setq mode-line-buffer-identification
        (telega-root--modeline-buffer-identification))

  (telega-filters--reset telega-filter-default)

  (setq buffer-read-only nil)
  (erase-buffer)

  ;; Status goes first
  (telega-button--insert
   'telega-status (cons telega--status telega--status-aux))

  ;; delim
  (insert "\n")
  (unless telega-root-compact-view
    (insert "\n"))

  ;; Custom filters
  (telega-filters--create)

  (save-excursion
    ;; NOTE: we are using ewoc with `nosep' so newline is not inserted
    ;; for non-visible chat buttons
    (goto-char (point-max))
    (insert "\n")
    (setq telega-root--ewoc
          (ewoc-create (if telega-debug
                           'telega-chat-known--pp
                         (telega-ewoc--gen-pp 'telega-chat-known--pp))
                       nil nil t))
    (dolist (chat telega--ordered-chats)
      (ewoc-enter-last telega-root--ewoc chat))

    ;; Contacts
    (goto-char (point-max))
    (insert "\n")
    (setq telega-contacts--ewoc
          (ewoc-create (if telega-debug
                           'telega-contact-root--pp
                         (telega-ewoc--gen-pp 'telega-contact-root--pp))
                       "" "" t))

    ;; Global search
    (goto-char (point-max))
    (insert "\n")
    (setq telega-search--ewoc
          (ewoc-create (if telega-debug
                           'telega-chat-global--pp
                         (telega-ewoc--gen-pp 'telega-chat-global--pp))
                       "" "" t))

    ;; Messages
    (goto-char (point-max))
    (insert "\n")
    (setq telega-messages--ewoc
          (ewoc-create (if telega-debug
                           'telega-msg-root--pp
                         (telega-ewoc--gen-pp 'telega-msg-root--pp))
                       "" "" t))
    )

  (setq buffer-read-only t)
  (add-hook 'kill-buffer-hook 'telega-root--killed nil t)

  (cursor-sensor-mode 1)
  (when telega-use-tracking
    (tracking-mode 1)))

(defun telega-root--killed ()
  "Run when telega root buffer is killed.
Terminate telega-server and kill all chat buffers."
  (when telega-status--timer
    (cancel-timer telega-status--timer))
  (when telega-search--timer
    (cancel-timer telega-search--timer))
  (telega-chats--kill-em-all)
  (telega-server-kill))

(defun telega-root--buffer ()
  "Return telega root buffer."
  (get-buffer telega-root-buffer-name))


;;; Auth/Connection Status
(define-button-type 'telega-status
  :supertype 'telega
  :inserter 'telega-ins--status
  'inactive t)

(defun telega-ins--status (status)
  "Default inserter for the `telega-status' button.
STATUS is cons with connection status as car and aux status as cdr."
  (let ((conn-status (car status))
        (aux-status (cdr status)))
    (telega-ins "Status: " conn-status)
    (unless (string-empty-p aux-status)
      (if (< (current-column) 28)
          (telega-ins (make-string (- 30 (current-column)) ?\s))
        (telega-ins "  "))
      (telega-ins aux-status))))

(defun telega-status--animate ()
  "Animate dots at the end of the current connection or/and aux status."
  (let ((conn-status (telega--animate-dots telega--status))
        (aux-status (telega--animate-dots telega--status-aux)))
    (when (or conn-status aux-status)
      (telega-status--set conn-status aux-status 'raw))))

(defun telega-status--timer-start ()
  "Start telega status animation timer."
  (when telega-status--timer
    (cancel-timer telega-status--timer))
  (setq telega-status--timer
        (run-with-timer telega-status-animate-interval
                        telega-status-animate-interval
                        #'telega-status--animate)))

(defun telega-status--set (conn-status &optional aux-status raw)
  "Set new status for the telegram connection to CONN-STATUS.
aux status is set to AUX-STATUS.  Both statuses can be `nil' to
unchange their current value.
If RAW is given then do not modify statuses for animation."
  (let ((old-status (cons telega--status telega--status-aux)))
    (when conn-status
      (setq telega--status conn-status))
    (when aux-status
      (setq telega--status-aux aux-status))

    (unless raw
      (telega-debug "Status: %s --> %s"
                    old-status (cons telega--status telega--status-aux))

      (cond ((string-match "ing" telega--status)
             (setq telega--status (concat telega--status "."))
             (telega-status--timer-start))
            ((string-match "\\.+$" telega--status-aux)
             (telega-status--timer-start))
            (telega-status--timer
             (cancel-timer telega-status--timer))))

  (with-telega-root-buffer
    (setq mode-line-process (concat ":" telega--status))
    (telega-save-cursor
      (let ((button (button-at (point-min))))
        (cl-assert (and button (eq (button-type button) 'telega-status))
                   nil "Telega status button is gone")
        (telega-button--update-value
         button (cons telega--status telega--status-aux)))))
  ))

(defun telega-root--redisplay ()
  "Redisplay root's buffer contents."
  (telega-filters--redisplay)

  (with-telega-root-buffer
    (telega-save-cursor
      (if telega-search-query
          ;; Setup headers of all the ewocs
          (let ((heading-attrs (list :min telega-root-fill-column
                                     :max telega-root-fill-column
                                     :align 'left
                                     :face 'telega-root-heading)))
            (telega-ewoc--set-header
             telega-root--ewoc
             (telega-ins--as-string
              (telega-ins--with-attrs
                  (nconc (list :elide t
                               :elide-trail (/ telega-root-fill-column 3))
                         heading-attrs)
                (telega-ins "Search: ")
                (telega-ins--with-face 'bold
                  (telega-ins telega-search-query))
                (telega-ins " ")
                (telega-ins--button "Cancel"
                  :action 'telega-search-cancel)
                (telega-ins " "))
              (telega-ins "\n")))

            (telega-ewoc--set-header
             telega-contacts--ewoc
             (telega-ins--as-string
              (telega-ins--with-attrs heading-attrs
                (telega-ins "CONTACTS"))
              (telega-ins "\n")))

            (telega-ewoc--set-header
             telega-search--ewoc
             (telega-ins--as-string
              (telega-ins--with-attrs heading-attrs
                ;; I18N: lng_search_global_results
                (telega-ins "GLOBAL SEARCH"))
              (telega-ins "\n")))

            (telega-ewoc--set-header
             telega-messages--ewoc
             (telega-ins--as-string
              (telega-ins--with-attrs heading-attrs
                (telega-ins "MESSAGES"))
              (telega-ins "\n"))))

        ;; No active search
        (ewoc-set-hf telega-search--ewoc "" "")
        (ewoc-set-hf telega-contacts--ewoc "" "")
        (ewoc-set-hf telega-messages--ewoc "" "")
        (telega-ewoc--set-header telega-root--ewoc ""))

      (ewoc-refresh telega-root--ewoc)
      (ewoc-refresh telega-contacts--ewoc)
      (ewoc-refresh telega-search--ewoc)
      (ewoc-refresh telega-messages--ewoc))))

(defun telega-root--chat-update (chat &optional for-reorder)
  "Something changed in CHAT, button needs to be updated.
If FOR-REORDER is non-nil, then CHAT's node is ok, just update filters."
  (telega-debug "IN: `telega-root--chat-update': %s" (telega-chat-title chat))

  (unless for-reorder
    (with-telega-root-buffer
      (telega-save-cursor
        (let ((enode (telega-ewoc--find-by-data
                      telega-root--ewoc chat)))
          (cl-assert enode nil "Ewoc node not found for chat:%s"
                     (telega-chat-title chat))
          (with-telega-deferred-events
            (ewoc-invalidate telega-root--ewoc enode))))))

  ;; Possible update chat in global search
  (let ((gnode (telega-ewoc--find-by-data
                telega-search--ewoc chat)))
    (when gnode
      (ewoc-invalidate telega-search--ewoc gnode)))

  ;; Update chats in searched messages
  (ewoc-map (lambda (msg)
              (eq chat (telega-msg-chat msg)))
            telega-messages--ewoc)

  (telega-filters--chat-update chat)
  (run-hook-with-args 'telega-chat-update-hook chat))

(defun telega-root--chat-reorder (chat &optional new-chat-p)
  "Move CHAT to correct place according to its order.
NEW-CHAT-P is used for optimization, to omit ewoc's node search."
  (with-telega-root-buffer
    (let* ((node (unless new-chat-p
                   (telega-ewoc--find-by-data telega-root--ewoc chat)))
           (chat-button (button-at (point)))
           (point-off (and telega-root-keep-cursor
                           chat-button
                           ;; If chat is deleted, postpone
                           ;; `telega-root-keep-cursor' behaviour
                           ;; Ignore custom order
                           (not (string= "0" (plist-get chat :order)))
                           (eq (button-get chat-button :value) chat)
                           (- (point) (button-start chat-button))))
           (chat-after (cadr (memq chat telega--ordered-chats)))
           (node-after (telega-ewoc--find-by-data
                        telega-root--ewoc chat-after)))
      (when node
        (ewoc-delete telega-root--ewoc node))
      (setq node
            (with-telega-deferred-events
              (if node-after
                  (ewoc-enter-before telega-root--ewoc node-after chat)
                (ewoc-enter-last telega-root--ewoc chat))))
      (cl-assert node)
      (when point-off
        (goto-char (ewoc-location node))
        (forward-char point-off)))))

(defun telega-root--chat-new (chat)
  "New CHAT has been created. Display it in root's ewoc."
  (telega-root--chat-reorder chat 'new-chat)

  ;; In case of initial chats load, redisplay custom filters
  ;; on every 50 chats loaded
  (when (and telega-filters--inhibit-redisplay
             (zerop (% (length telega--ordered-chats) 50)))
    (let ((telega-filters--inhibit-redisplay nil))
      (telega-filters--redisplay))))

(defun telega-root--modeline-buffer-identification ()
  "Return `mode-line-buffer-identification' for the root buffer."
  (let* ((title "%12b")
         (uu-chats-count
          (or (plist-get telega--unread-chat-count :unread_unmuted_count) 0))
         (unread-unmuted
          (unless (zerop uu-chats-count)
            (propertize (format " %d" uu-chats-count)
                        'face 'telega-unread-unmuted-modeline
                        'local-map
                        '(keymap
                          (mode-line
                           keymap (mouse-1 . telega-filter-unread-unmuted)))
                        'mouse-face 'mode-line-highlight
                        'help-echo
                        "Click to filter chats with unread/unmuted messages")))
         ;; TODO: unread mentions count
         ;; see https://github.com/tdlib/td/issues/510
         )
    (when (display-graphic-p)
      (let ((logo-img (or telega--logo-image-cache
                          (setq telega--logo-image-cache
                                (find-image
                                 '((:type xpm :file "etc/telegram-logo.xpm"
                                          :ascent center)))))))
        (setq title (concat "  " title))
        (add-text-properties 0 1 (list 'display logo-img) title)))

    (list title unread-unmuted)))

(defun telega--on-updateUnreadMessageCount (event)
  "Number of unread messages has changed."
  (setq telega--unread-message-count (cddr event))

  (with-telega-root-buffer
    (setq mode-line-buffer-identification
          (telega-root--modeline-buffer-identification))
    (force-mode-line-update)))

(defun telega--on-updateUnreadChatCount (event)
  "Number of unread/unmuted chats has been changed."
  (setq telega--unread-chat-count (cddr event))

  (with-telega-root-buffer
    (setq mode-line-buffer-identification
          (telega-root--modeline-buffer-identification))
    (force-mode-line-update)))


;;; Searching global public chats and messages
(defun telega-search--animate ()
  "Animate loading dots for the footers of search ewocs."
  (let ((new-sf (telega--animate-dots
                 (cdr (ewoc-get-hf telega-search--ewoc))))
        (new-mf (telega--animate-dots
                 (cdr (ewoc-get-hf telega-messages--ewoc)))))
    (with-telega-root-buffer
      (telega-save-cursor
        (when new-sf
          (telega-ewoc--set-footer telega-search--ewoc (concat new-sf "\n")))
        (when new-mf
          (telega-ewoc--set-footer telega-messages--ewoc (concat new-mf "\n")))))

    (unless (or new-sf new-mf)
      (cancel-timer telega-search--timer))))

(defun telega-search--timer-start ()
  (when telega-search--timer
    (cancel-timer telega-search--timer))
  (setq telega-search--timer
        (run-with-timer telega-status-animate-interval
                        telega-status-animate-interval
                        #'telega-search--animate)))

(defun telega-root--messages-chats ()
  "Return chats of the searched messages."
  (mapcar 'telega-msg-chat (ewoc-collect telega-messages--ewoc 'identity)))

(defun telega-root--messages-search (&optional last-msg)
  "Search the messages with `telega-search-query'.
If LAST-MSG is specified, then continue searching."
  (cl-assert (not telega--search-messages-loading))
  (setq telega--search-messages-loading
        (telega--searchMessages
         telega-search-query last-msg
         'telega-root--messages-add))

  (with-telega-root-buffer
    (telega-save-cursor
      (telega-ewoc--set-footer telega-messages--ewoc "Loading..\n")
      (telega-search--timer-start))))

(defun telega-root--messages-add (messages)
  "Add MESSAGES to the `telega-messages--ewoc'."
  (setq telega--search-messages-loading nil)
  (with-telega-root-buffer
    (telega-save-cursor
      (telega-ewoc--set-footer telega-messages--ewoc "")
      (dolist (msg messages)
        (ewoc-enter-last telega-messages--ewoc msg))

      (telega-filters-apply 'no-root-redisplay)

      ;; If none of the messages is visible (according to active
      ;; filters) and last-msg is available, then fetch more messages
      ;; automatically.
      ;; Otherwise, when at least one message is display, show
      ;; "Load More" button
      (let ((last-msg (car (last messages))))
        (when last-msg
          (if (telega-ewoc--empty-p telega-messages--ewoc)
              ;; no nodes visible, fetch next automatically
              (telega-root--messages-search last-msg)

            (telega-ewoc--set-footer
             telega-messages--ewoc
             (telega-ins--as-string
              (telega-ins--button "Load More"
                :value last-msg
                :action 'telega-root--messages-search))))
          )))))

(defun telega-root--global-chats ()
  "Return globally found chats."
  (ewoc-collect telega-search--ewoc 'identity))

(defun telega-root--global-search ()
  "Globally search for public chats with `telega-search-query'"
  (cl-assert (not telega--search-global-loading))
  ;; telega--searchPublicChats may return nil, meaning no search is
  ;; done.  For example if query is less then 5 chars
  (when (setq telega--search-global-loading
              (telega--searchPublicChats
               telega-search-query 'telega-root--global-add))
    (with-telega-root-buffer
      (telega-save-cursor
        (telega-ewoc--set-footer telega-search--ewoc "Loading.\n")
        (telega-search--timer-start)))))

(defun telega-root--global-add (chats)
  "Add CHATS to `telega-search--ewoc'."
  (setq telega--search-global-loading nil)
  (with-telega-root-buffer
    (telega-save-cursor
      (telega-ewoc--set-footer telega-search--ewoc "")
      (dolist (chat chats)
        ;; XXX fetch full-info before inserting, so chat update events
        ;; won't be triggered inside chat inserter
        (telega--full-info (telega-chat--info chat))
        (ewoc-enter-last telega-search--ewoc chat))

      (telega-filters-apply 'no-root-redisplay))))

(defun telega-search-async--cancel ()
  "Cancel async searches."
  (with-telega-root-buffer
    (telega-save-cursor
      (telega-ewoc--clean telega-search--ewoc)
      (telega-ewoc--clean telega-contacts--ewoc)
      (telega-ewoc--clean telega-messages--ewoc)))

  (when telega--search-global-loading
    (telega-server--callback-put telega--search-global-loading 'ignore)
    (setq  telega--search-global-loading nil))
  (when telega--search-messages-loading
    (telega-server--callback-put telega--search-messages-loading 'ignore)
    (setq telega--search-messages-loading nil)))

(defun telega-search-cancel (&rest _ignoredargs)
  "Cancel currently active search results."
  (interactive)
  (telega-search-async--cancel)
  (setq telega-search-query nil)
  (setq telega--search-chats nil)
  (setq telega--search-contacts nil)

  (telega-filters-apply))

(defun telega-search (cancel-p)
  "Search for the QUERY in chats, global public chats and messages.
If used with PREFIX-ARG, then cancel current search."
  (interactive "P")
  (if cancel-p
      (telega-search-cancel)

    (let ((query (read-string "Search for: " nil 'telega-search-history)))
      ;; Always move cursor to the search title
      (goto-char (telega-ewoc--location telega-root--ewoc))

      ;; Asynchronously load results from global search for chats and
      ;; messages
      (telega-search-async--cancel)

      (setq telega-search-query query)
      (setq telega--search-chats
            (telega--searchChats query))

      (setq telega--search-contacts
            (telega--searchContacts query))
      ;; NOTE: filter out contacts, that are already in `telega--search-chats'
      ;; (setq telega--search-contacts
      ;;       (cl-remove-if (lambda (contact)
      ;;                       (telega-filter-chats
      ;;                        (list 'ids (plist-get contact :id))
      ;;                        telega--search-chats))
      ;;                     (telega--searchContacts query)))
      (dolist (contact telega--search-contacts)
        (ewoc-enter-last telega-contacts--ewoc contact))

      (telega-root--global-search)
      (telega-root--messages-search)

      (telega-filters-apply))))

(provide 'telega-root)

;;; telega-root.el ends here
