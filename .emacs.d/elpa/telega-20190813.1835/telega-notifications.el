;;; telega-notifications.el --- Notifications support for telega  -*- lexical-binding:t -*-

;; Copyright (C) 2018-2019 by Zajcev Evgeny.

;; Author: Zajcev Evgeny <zevlg@yandex.ru>
;; Created: Wed Apr 18 18:18:22 2018
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

;; Notification pop-ups using `notifications.el' for incoming messages
;; and calls.
;; 
;; To enable notifications use next code in your init.el:
;; 
;;   (setq telega-use-notifications t)
;;
;; before loading telega, or (telega-notifications-mode 1) in runtime
;; 

;;; Code:
(require 'cl-lib)
(require 'notifications)

(require 'telega-core)
(require 'telega-util)

(declare-function telega-chat--type "telega-chat" (chat &optional no-interpret))
(declare-function telega-chat-get "telega-chat" (chat-id &optional offline-p))
(declare-function telega-chat-title "telega-chat" (chat &optional with-username))


(defvar telega-notifications--last-id nil
  "Currently shown notification.")

(defun telega-chat-notification-setting (chat setting &optional default-p)
  "For the CHAT return NOTIFICATION-SETTING value.
If DEFAULT-P is non-nil then return default setting for the CHAT."
  (let ((use-default-name
         (intern (concat ":use_default_" (substring (symbol-name setting) 1))))
        (not-cfg (plist-get chat :notification_settings))
        (default-cfg nil))
    (when (or default-p (plist-get not-cfg use-default-name))
      (setq default-cfg
            (cl-case (telega-chat--type chat)
              (channel
               (alist-get 'channel telega--scope-notification-alist))
              ((basicgroup supergroup)
               (alist-get 'group telega--scope-notification-alist))
              (t
               (alist-get 'private telega--scope-notification-alist)))))

    (plist-get (or default-cfg not-cfg) setting)))

(defun telega--setScopeNotificationSettings (scope-type setting)
  (telega-server--call
   (list :@type "setScopeNotificationSettings"
         :scope (list :@type scope-type)
         :notification_settings
         `(:@type "scopeNotificationSettings" ,@setting))))

(defun telega--getScopeNotificationSettings (scope-type &optional callback)
  (telega-server--call
   (list :@type "getScopeNotificationSettings"
         :scope (list :@type scope-type))
   callback))

(defun telega--resetAllNotificationSettings ()
  "Resets all notification settings to their default values.
By default, all chats are unmuted, the sound is set to
\"default\" and message previews are shown."
  (telega-server--call
   (list :@type "resetAllNotificationSettings")))

(defun telega--on-updateScopeNotificationSettings (event)
  "Handle `updateScopeNotificationSettings' EVENT."
  (let* ((scope (plist-get event :scope))
         (scope-key (cl-ecase (telega--tl-type scope)
                      (notificationSettingsScopePrivateChats 'private)
                      (notificationSettingsScopeGroupChats 'group)
                      (notificationSettingsScopeChannelChats 'channel))))
    (setf (alist-get scope-key telega--scope-notification-alist)
          (plist-get event :notification_settings))))

(defun telega-ins--msg-notification (msg)
  "Inserter to format MSG to notify about."
  ;; Limit length of the message
  (telega-ins--with-attrs (list :max telega-notifications-msg-body-limit
                                :elide t)
    (let ((chat (telega-chat-get (plist-get msg :chat_id))))
      (unless (memq (telega-chat--type chat 'raw) '(private secret))
        (when (telega-ins--username (plist-get msg :sender_user_id) 'name)
          (telega-ins ": "))
        (when (telega-ins--via-bot (plist-get msg :via_bot_user_id))
          (telega-ins "\n"))))

    (telega-ins--content msg)))

(defun telega-ins--notification-scope (scope-type sconf)
  "Insert notification scope."
  (let* ((mute-for (plist-get sconf :mute_for))
         (unmuted-p (zerop mute-for))
         (sound (plist-get sconf :sound))
         (preview-p (plist-get sconf :show_preview)))
    (telega-ins "Show Notifications: ")
    (telega-ins--button (if unmuted-p
                            telega-symbol-heavy-checkmark
                          "  ")
      'action (lambda (_button)
                (telega--setScopeNotificationSettings
                 scope-type (list :mute_for (if unmuted-p 599634793 0)
                                  :sound sound
                                  :show_preview (or preview-p :false)))
                (telega-save-cursor
                  (telega-describe-notifications))))
    (telega-ins "\n")
    (telega-ins "Show Preview: ")
    (telega-ins--button (if preview-p
                            telega-symbol-heavy-checkmark
                          "  ")
      'action (lambda (_button)
                (telega--setScopeNotificationSettings
                 scope-type (list :mute_for mute-for
                                  :sound sound
                                  :show_preview (if preview-p :false t)))
                (telega-save-cursor
                  (telega-describe-notifications))))
    (telega-ins "\n")
    (telega-ins "Sound: " (if (string-empty-p sound) "None" sound) "\n")
    ))

(defun telega-describe-notifications (&rest _ignored)
  "Show global notifications settings."
  (interactive)
  (with-telega-help-win "*Telega Notifications*"
    (telega-ins--with-face 'bold
      (telega-ins "Private/Secret chats:\n"))
    (telega-ins--notification-scope
     "notificationSettingsScopePrivateChats"
     (alist-get 'private telega--scope-notification-alist))
    (telega-ins "\n")
    ;; TODO: exceptions

    (telega-ins--with-face 'bold
      (telega-ins "Group chats:\n"))
    (telega-ins--notification-scope
     "notificationSettingsScopeGroupChats"
     (alist-get 'group telega--scope-notification-alist))

    (telega-ins--with-face 'bold
      (telega-ins "Channel chats:\n"))
    (telega-ins--notification-scope
     "notificationSettingsScopeChannelChats"
     (alist-get 'channel telega--scope-notification-alist))

    (telega-ins "\n")
    (telega-ins--button "Reset All Notifications"
      'action (lambda (_button)
                (when (y-or-n-p "Reset all notifications settings? ")
                  (telega--resetAllNotificationSettings)
                  (telega-save-cursor
                    (telega-describe-notifications)))))
    (telega-ins "\n")
    (telega-ins--with-face 'shadow
      (telega-ins " Undo all custom notification settings for all chats"))
    (telega-ins "\n")
    ))

;;;###autoload
(defun telega-notifications-mode (&optional arg)
  "Toggle telega notifications on or off.
With positive ARG - enables notifications, otherwise disables.
If ARG is not given then treat it as 1."
  (interactive "p")
  (if (or (null arg) (> arg 0))
      (progn
        (add-hook 'telega-chat-post-message-hook 'telega-notifications-chat-message)
        (add-hook 'telega-call-incoming-hook 'telega-notifications-incoming-call))
    (remove-hook 'telega-chat-post-message-hook 'telega-notifications-chat-message)
    (remove-hook 'telega-call-incoming-hook 'telega-notifications-incoming-call)))

(defcustom telega-use-notifications nil
  "*Non-nil to enable D-Bus notifications for unmuted chats.
If non-nil also enable notification for incoming calls."
  :type 'boolean
  :group 'telega
  :set (lambda (opt val)
         (set-default opt val)
         (telega-notifications-mode (if val 1 -1))))

(defun telega-notifications--close (id)
  "Close notification by ID."
  (when (eq telega-notifications--last-id id)
    (notifications-close-notification id)
    (setq telega-notifications--last-id nil)))

(defun telega-notifications--notify (notify-spec)
  (when telega-notifications--last-id
    (notifications-close-notification telega-notifications--last-id))
  (let* ((base-spec (list :app-name "emacs.telega"
                          :app-icon (telega-etc-file "telegram-logo.svg")
                          ;; NOTE: with this param popups stucks sometimes
                          ;; So we use timer to manually remove the popup
                          ;; Or newly arrived notifications also
                          ;; removes current popup
                          :timeout 0
;                          :timeout (round (* 1000 telega-notifications-timeout))
                          :urgency "normal"))
         ;; DO NOT modify NOTIFY-SPEC
         (notify-args (append notify-spec base-spec)))
    (telega-debug "NOTIFY with args: %S" notify-args)
    (setq telega-notifications--last-id
          (apply 'notifications-notify notify-args))))

(defun telega-notifications--chat-msg0 (msg)
  "Function called after `telega-notifications-delay' delay."
  ;; Checks once more that message has not yet been read in another
  ;; telegram client
  (let* ((msg-id (plist-get msg :id))
         (chat-id (plist-get msg :chat_id))
         (chat (telega-chat-get chat-id)))
    (unless (telega-msg-seen-p msg chat)
      (let ((notify-args
             (nconc
              (list :actions (list "default" "show message")
                    :on-action `(lambda (&rest args)
                                  (x-focus-frame (telega-x-frame))
                                  (telega-chat--goto-msg
                                   (telega-chat-get ,chat-id)
                                   ,msg-id 'highlight))
                    :title (telega-chat-title chat 'with-username)
                    :body (if (telega-chat-notification-setting chat :show_preview)
                              (telega--desurrogate-apply
                               (telega-ins--as-string
                                (funcall telega-inserter-for-msg-notification msg)))
                            "Has new unread messages"))
              telega-notifications-msg-args)))
        ;; Play sound only if CHAT setting has some sound
        (when (string-empty-p
               (or (telega-chat-notification-setting chat :sound) ""))
          (setq notify-args (telega-plist-del notify-args :sound-name)))

        (telega-notifications--notify notify-args)
        ;; Workaround stuck notifications, force closing after
        ;; `telega-notifications-timeout' timeout
        (run-with-timer telega-notifications-timeout nil
                        'telega-notifications--close
                        telega-notifications--last-id)
        ))))

(defun telega-notifications-chat-message (msg)
  "Function intended to be added to `telega-chat-post-message-hook'."
  ;; Do NOT notify message if:
  ;;  - Message is ignored by client side filtering (see `telega-msg-ignored-p')
  ;;  - Chat is muted
  ;;  - Message already has been read (see `telega-msg-seen-p')
  ;;  - Message is older then 1 min (to avoid poping up messages on
  ;;    laptop wakeup)
  ;;  - Message is currently observable in chatbuf
  ;;  - [TODO] If Emacs frame has focus and root buffer is current
  (unless (or (telega-msg-ignored-p msg)
              (> (- (time-to-seconds) (plist-get msg :date)) 60))
    (let ((chat (telega-msg-chat msg)))
      (unless (or (telega-msg-seen-p msg chat)
                  (not (zerop (telega-chat-notification-setting chat :mute_for)))
                  (telega-msg-observable-p msg chat))
        (if (> telega-notifications-delay 0)
            (run-with-timer telega-notifications-delay nil
                            'telega-notifications--chat-msg0 msg)
          ;; No delay
          (telega-notifications--chat-msg0 msg))))))

(defun telega-notifications-incoming-call (call)
  "Function intended to be added to `telega-call-incoming-hook'."
  (let* ((call-id (plist-get call :id))
         (user (telega-user--get (plist-get call :user_id)))
         (notargs (list :actions (list "default" "accept")
                        :on-action `(lambda (&rest args)
                                      (x-focus-frame (telega-x-frame))
                                      (telega-voip-accept
                                       (telega-voip--by-id ,call-id)))
                        :timeout 0
                        ;; I18N: lng_call_incoming
                        :title "Incoming call"
                        :body (format "from %s" (telega-user--name user)))))
    (telega-notifications--notify
     (nconc notargs telega-notifications-call-args))))

(provide 'telega-notifications)

;;; telega-notifications.el ends here
