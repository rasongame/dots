;;; telega-msg.el --- Messages for telega  -*- lexical-binding:t -*-

;; Copyright (C) 2018-2019 by Zajcev Evgeny.

;; Author: Zajcev Evgeny <zevlg@yandex.ru>
;; Created: Fri May  4 03:49:22 2018
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
(require 'format-spec)

(require 'telega-core)
(require 'telega-customize)
(require 'telega-media)
(require 'telega-ffplay)                ; telega-ffplay-run
(require 'telega-vvnote)

(defvar telega-msg-button-map
  (let ((map (make-sparse-keymap)))
    (set-keymap-parent map button-map)
    (define-key map [remap self-insert-command] 'ignore)
    (define-key map (kbd "n") 'telega-button-forward)
    (define-key map (kbd "p") 'telega-button-backward)

    (define-key map (kbd "i") 'telega-describe-message)
    (define-key map (kbd "r") 'telega-msg-reply)
    (define-key map (kbd "e") 'telega-msg-edit)
    (define-key map (kbd "f") 'telega-msg-forward)
    (define-key map (kbd "d") 'telega-msg-delete)
    (define-key map (kbd "k") 'telega-msg-delete)
    (define-key map (kbd "l") 'telega-msg-redisplay)
    (define-key map (kbd "R") 'telega-msg-resend)
    (define-key map (kbd "S") 'telega-msg-save)
    (define-key map (kbd "DEL") 'telega-msg-delete)
    map))

(define-button-type 'telega-msg
  :supertype 'telega
  :inserter telega-inserter-for-msg-button
  'read-only t
  'keymap telega-msg-button-map
  'action 'telega-msg-button--action)

(defun telega-msg-button--action (button)
  "Action to take when chat BUTTON is pressed."
  (let ((msg (telega-msg-at button))
        ;; If custom `:action' is used for the button, then use it,
        ;; otherwise open content
        (custom-action (button-get button :action)))
    (cl-assert msg)
    (if custom-action
        (funcall custom-action msg)
      (telega-msg-open-content msg))))

(defun telega-msg--pp (msg)
  "Pretty printer for MSG button."
  ;; NOTE: check that we can group messages by sender
  ;; see `telega-chat-group-messages-for'
  (if (and (telega-filter--test
            (telega-msg-chat msg) telega-chat-group-messages-for)
           (> (point) 3)
           (let ((prev-msg (telega-msg-at (- (point) 2))))
             (and (not (telega-msg-special-p prev-msg))
                  (eq (plist-get msg :sender_user_id)
                      (plist-get prev-msg :sender_user_id)))))
      (telega-button--insert 'telega-msg msg
        :inserter 'telega-ins--message-no-header)
    (telega-button--insert 'telega-msg msg))
  (telega-ins "\n"))

(defun telega-msg-root--pp (msg)
  "Pretty printer for MSG button shown in root buffer."
  (let ((visible-p (telega-filter-chats nil (list (telega-msg-chat msg)))))
    (when visible-p
      (telega-button--insert 'telega-msg msg
        :inserter 'telega-ins--root-msg
        :action 'telega-msg-goto-highlight)
      (telega-ins "\n"))))

(defun telega-msg--get (chat-id msg-id &optional locally-p callback)
  "Get message by CHAT-ID and MSG-ID pair.
If LOCALLY-P is non-nil, then do not perform request to telega-server.
If CALLBACK is specified and message is not available at the
moment, then fetch message asynchronously and call the CALLBACK
function with one argument - message."
  (let ((cached-msg (with-telega-chatbuf (telega-chat-get chat-id)
                      (telega-chatbuf--msg msg-id))))
    (if (or locally-p cached-msg)
        cached-msg

      ;; Perform request to the telega-server
      (let ((ret (telega-server--call
                  (list :@type "getMessage"
                        :chat_id chat-id
                        :message_id msg-id)
                  (when callback
                    (lambda (reply)
                      (funcall callback
                               (unless (telega--tl-error-p reply)
                                 reply)))))))
        ;; Probably message already deleted
        (if callback
            ret
          (unless (telega--tl-error-p ret)
            ret))))))

(defun telega-msg--cache-in-chatbuf (msg)
  "Cache message MSG in corresponding chatbuf messages cache."
  (with-telega-chatbuf (telega-msg-chat msg)
    (telega-chatbuf--cache-msg msg)))

(defsubst telega-msg-list-get (tl-obj-Messages)
  "Return messages list of TL-OBJ-MESSAGES represeting `Messages' object."
  (mapcar #'identity (plist-get tl-obj-Messages :messages)))

(defun telega-msg-at (&optional pos)
  "Return current message at point."
  (let ((button (button-at (or pos (point)))))
    (when (and button (eq (button-type button) 'telega-msg))
      (button-get button :value))))

(defsubst telega-msg-chat (msg)
  "Return chat for the MSG."
  (telega-chat-get (plist-get msg :chat_id)))

(defun telega-msg-reply-msg (msg &optional locally-p callback)
  "Return message MSG replying to.
If LOCALLY-P is non-nil, then do not perform any requests to telega-server.
If CALLBACK is specified, then get reply message asynchronously."
  (declare (indent 2))
  (let ((reply-to-msg-id (plist-get msg :reply_to_message_id)))
    (unless (zerop reply-to-msg-id)
      (telega-msg--get
       (plist-get msg :chat_id) reply-to-msg-id locally-p callback))))

(defsubst telega-msg-goto (msg &optional highlight)
  "Goto message MSG."
  (telega-chat--goto-msg
   (telega-msg-chat msg) (plist-get msg :id) highlight))

(defsubst telega-msg-goto-highlight (msg)
  "Goto message MSG and hightlight it."
  (telega-msg-goto msg 'hightlight))

(defun telega--openMessageContent (msg)
  "Open content of the message MSG."
  (telega-server--send
   (list :@type "openMessageContent"
         :chat_id (plist-get msg :chat_id)
         :message_id (plist-get msg :id))))

(defun telega-msg-open-sticker (msg)
  "Open content for sticker message MSG."
  (let ((sset-id (telega--tl-get msg :content :sticker :set_id)))
    (telega-describe-stickerset
     (telega-stickerset-get sset-id) (telega-msg-chat msg))))

;; TODO: revise the code, too much similar stuff
(defun telega-msg-open-video (msg)
  "Open content for video message MSG."
  (let* ((video (telega--tl-get msg :content :video))
         (video-file (telega-file--renew video :video)))
    ;; NOTE: `telega-file--download' triggers callback in case file is
    ;; already downloaded
    (telega-file--download video-file 32
      (lambda (file)
        (telega-msg-redisplay msg)
        (when (telega-file--downloaded-p file)
          (apply 'telega-ffplay-run
                 (telega--tl-get file :local :path) nil
                 telega-video-ffplay-args))))))

(defun telega-msg-open-audio (msg)
  "Open content for audio message MSG."
  ;; - If already playing, then pause
  ;; - If paused, start from paused position
  ;; - If not start, start playing
  (let* ((audio (telega--tl-get msg :content :audio))
         (audio-file (telega-file--renew audio :audio))
         (proc (plist-get msg :telega-audio-proc)))
    (cl-case (and (process-live-p proc) (process-status proc))
      (run (telega-ffplay-pause proc))
      (stop (telega-ffplay-resume proc))
      (t (telega-file--download audio-file 32
          (lambda (file)
            (telega-msg-redisplay msg)
            (when (telega-file--downloaded-p file)
              (plist-put msg :telega-audio-proc
                         (telega-ffplay-run
                          (telega--tl-get file :local :path)
                          (lambda (_proc)
                            (telega-msg-redisplay msg))
                          "-nodisp")))))))))

(defun telega-msg-voice-note--ffplay-callback (msg)
  "Return callback to be used in `telega-ffplay-run'."
  (lambda (proc)
    (telega-msg-redisplay msg)

    (unless (process-live-p proc)
      (telega-msg-activate-voice-note nil (telega-msg-chat msg)))

    (when (and (eq (process-status proc) 'exit)
               telega-vvnote-voice-play-next)
      ;; ffplay exited normally (finished playing), try to play next
      ;; voice message if any
      (let ((next-voice-msg (telega-chatbuf--next-voice-msg msg)))
        (when next-voice-msg
          (telega-msg-open-content next-voice-msg))))))

(defun telega-msg-open-voice-note (msg)
  "Open content for voiceNote message MSG."
  ;; - If already playing, then pause
  ;; - If paused, start from paused position
  ;; - If not start, start playing
  (let* ((note (telega--tl-get msg :content :voice_note))
         (note-file (telega-file--renew note :voice))
         (proc (plist-get msg :telega-vvnote-proc)))
    (cl-case (and (process-live-p proc) (process-status proc))
      (run (telega-ffplay-pause proc))
      (stop (telega-ffplay-resume proc))
      (t (telega-file--download note-file 32
          (lambda (file)
            (telega-msg-redisplay msg)
            (when (telega-file--downloaded-p file)
              (plist-put msg :telega-vvnote-proc
                         (telega-ffplay-run
                          (telega--tl-get file :local :path)
                          (telega-msg-voice-note--ffplay-callback msg)
                          "-nodisp"))
              (telega-msg-activate-voice-note msg))))))
    ))

(defun telega-msg-open-video-note (msg)
  "Open content for videoNote message MSG."
  (let* ((note (telega--tl-get msg :content :video_note))
         (note-file (telega-file--renew note :video)))
    ;; NOTE: `telega-file--download' triggers callback in case file is
    ;; already downloaded
    (telega-file--download note-file 32
      (lambda (file)
        (telega-msg-redisplay msg)
        (when (telega-file--downloaded-p file)
          (telega-ffplay-run
           (telega--tl-get file :local :path) nil))))))

(defun telega-msg-open-photo (msg)
  "Open content for photo message MSG."
  (telega-photo--open (telega--tl-get msg :content :photo) msg))

(defun telega-msg-open-animation (msg)
  "Open content for animation message MSG."
  (let* ((anim (telega--tl-get msg :content :animation))
         (anim-file (telega-file--renew anim :animation)))
    ;; NOTE: `telega-file--download' triggers callback in case file is
    ;; already downloaded
    (telega-file--download anim-file 32
      (lambda (file)
        (telega-msg-redisplay msg)
        (when (telega-file--downloaded-p file)
          (telega-ffplay-run
           (telega--tl-get file :local :path) nil
           "-loop" "0"))))))

(defun telega-msg-open-document (msg)
  "Open content for document message MSG."
  (let* ((doc (telega--tl-get msg :content :document))
         (doc-file (telega-file--renew doc :document)))
    (telega-file--download doc-file 32
      (lambda (file)
        (telega-msg-redisplay msg)
        (when (telega-file--downloaded-p file)
          (find-file (telega--tl-get file :local :path)))))))

(defun telega-msg-open-location (msg)
  "Open content for location message MSG."
  (let* ((loc (telega--tl-get msg :content :location))
         (lat (plist-get loc :latitude))
         (lon (plist-get loc :longitude))
         (url (format-spec telega-location-url-format
                           (format-spec-make ?N lat ?E lon))))
    (telega-browse-url url 'in-web-browser)))

(defun telega-msg-open-contact (msg)
  "Open content for contact message MSG."
  (telega-describe-contact
   (telega--tl-get msg :content :contact)))

(defun telega-msg-open-content (msg)
  "Open message MSG content."
  (telega--openMessageContent msg)

  (cl-case (telega--tl-type (plist-get msg :content))
    (messageDocument
     (telega-msg-open-document msg))
    (messageSticker
     (telega-msg-open-sticker msg))
    (messageVideo
     (telega-msg-open-video msg))
    (messageAudio
     (telega-msg-open-audio msg))
    (messageAnimation
     (telega-msg-open-animation msg))
    (messageVoiceNote
     (telega-msg-open-voice-note msg))
    (messageVideoNote
     (telega-msg-open-video-note msg))
    (messagePhoto
     (telega-msg-open-photo msg))
    (messageLocation
     (telega-msg-open-location msg))
    (messageContact
     (telega-msg-open-contact msg))
    (messageText
     (let* ((web-page (telega--tl-get msg :content :web_page))
            (url (plist-get web-page :url)))
       (when url
         (telega-browse-url url))))
    (t (message "TODO: `open-content' for <%S>"
                (telega--tl-type (plist-get msg :content))))))

(defun telega-msg--track-file-uploading-progress (msg)
  "Track uploading progress for the file associated with MSG."
  (let ((msg-file (telega-file--used-in-msg msg)))
    (when (and msg-file (telega-file--uploading-p msg-file))
      (telega-file--upload-internal msg-file
        (lambda (_filenotused)
          (telega-msg-redisplay msg))))))

(defun telega--getPublicMessageLink (chat-id msg-id &optional for-album)
  "Get https link to public message."
  (telega-server--call
   (list :@type "getPublicMessageLink"
         :chat_id chat-id
         :message_id msg-id
         :for_album (or for-album :false))))

(defun telega-msg-public-link (msg &optional for-album)
  "Return public http link for the message MSG."
  (plist-get
   (telega--getPublicMessageLink
    (plist-get (telega-msg-chat msg) :id) (plist-get msg :id) for-album)
   :link))

(defun telega--deleteMessages (chat-id message-ids &optional revoke)
  "Delete messages by its MESSAGES-IDS list.
If REVOKE is non-nil then delete message for all users."
  (telega-server--send
   (list :@type "deleteMessages"
         :chat_id chat-id
         :message_ids (apply 'vector message-ids)
         :revoke (or revoke :false))))

(defun telega--forwardMessages (chat-id from-chat-id message-ids
                                        &optional disable-notification
                                        from-background as-album)
  "Forwards previously sent messages.
Returns the forwarded messages.
Return nil if message can't be forwarded."
  (error "`telega--forwardMessages' Not yet implemented"))

(defun telega--searchMessages (query last-msg &optional callback)
  "Search messages by QUERY.
Specify LAST-MSG to continue searching from LAST-MSG searched.
If CALLBACK is specified, then do async call and run CALLBACK
with list of chats received."
  (let ((ret (telega-server--call
              (list :@type "searchMessages"
                    :query query
                    :offset_date (or (plist-get last-msg :date) 0)
                    :offset_chat_id (or (plist-get last-msg :chat_id) 0)
                    :offset_message_id (or (plist-get last-msg :id) 0)
                    :limit 100)
              (and callback
                   `(lambda (reply)
                      (funcall ',callback (telega-msg-list-get reply)))))))
      (if callback
          ret
        (telega-msg-list-get ret))))

(defun telega-msg-chat-title (msg)
  "Title of the message's chat."
  (telega-chat-title (telega-msg-chat msg) 'with-username))

(defsubst telega-msg-sender (msg)
  "Return sender (if any) for message MSG."
  (let ((sender-uid (plist-get msg :sender_user_id)))
    (unless (zerop sender-uid)
      (telega-user--get sender-uid))))

(defsubst telega-msg-by-me-p (msg)
  "Return non-nil if sender of MSG is me."
  (= (plist-get msg :sender_user_id) telega--me-id))

(defsubst telega-msg-seen-p (msg &optional chat)
  "Return non-nil if MSG has been already read in CHAT."
  (unless chat (setq chat (telega-msg-chat msg)))
  (<= (plist-get msg :id) (plist-get chat :last_read_inbox_message_id)))

(defun telega-msg-observable-p (msg &optional chat node)
  "Return non-nil if MSG is observable in chatbuffer.
CHAT - chat to search message for.
NODE - ewoc node, if known."
  (unless chat (setq chat (telega-msg-chat msg)))
  (with-telega-chatbuf chat
    (unless node
      (setq node (telega-chatbuf--node-by-msg-id (plist-get msg :id))))
    (when node
      (telega-button--observable-p (ewoc-location node)))))

;; DEPRECATED ???
(defun telega-msg-sender-admin-status (msg)
  (let ((admins-tl (telega-server--call
                    (list :@type "getChatAdministrators"
                          :chat_id (plist-get msg :chat_id)))))
    (when (cl-find (plist-get msg :sender_user_id)
                   (plist-get admins-tl :user_ids)
                   :test #'=)
      " (admin)")))

(defun telega--parseTextEntities (text parse-mode &optional no-error)
  "Parse TEXT using PARSE-MODE.
PARSE-MODE is one of: \"textParseModeMarkdown\" or \"textParseModeHTML\".
If NO-ERROR is non-nil and TEXT can't be do not raise an error, return nil."
  (let ((fmt-text (telega-server--call
                   (list :@type "parseTextEntities"
                         :text text
                         :parse_mode (list :@type parse-mode)))))
    (unless (or fmt-text no-error)
      (cl-assert telega-server--last-error)
      (user-error (plist-get telega-server--last-error :message)))
    (plist-put fmt-text :text (telega--desurrogate-apply (plist-get fmt-text :text)))))

(defun telega--formattedText (text &optional markdown)
  "Convert TEXT to `formattedTex' type.
If MARKDOWN is non-nil then format TEXT as markdown."
  (if markdown
      (telega--parseTextEntities text "textParseModeMarkdown")
    (list :@type "formattedText"
          :text (substring-no-properties text) :entities [])))

(defun telega--stopPoll (msg)
  "Stops a poll."
  (telega-server--send
   (list :@type "stopPoll"
         :chat_id (plist-get (telega-msg-chat msg) :id)
         :message_id (plist-get msg :id))))

(defun telega--setPollAnswer (msg option-id)
  "Changes user answer to a poll.
OPTION-ID - 0-based identifiers of option, chosen by the user."
  (telega-server--send
   (list :@type "setPollAnswer"
         :chat_id (plist-get (telega-msg-chat msg) :id)
         :message_id (plist-get msg :id)
         :option_ids (vector option-id))))

;;; Ignoring messages
(defmacro telega-msg-ignored-p (msg)
  `(plist-get ,msg :ignored-p))
(defun telega-msg-ignore (msg)
  "Mark message MSG to be ignored (not viewed, notified about) in chats.
By side effect adds MSG into `telega--ignored-messages-ring' to be viewed
with `M-x telega-ignored-messages RET'."
  (plist-put msg :ignored-p t)
  (ring-insert telega--ignored-messages-ring msg)
  (telega-debug "IGNORED msg: %S" msg))

(defun telega-msg-ignore-blocked-sender (msg &rest not-used)
  "Function to be used as `telega-chat-pre-message-hook'.
Add it to `telega-chat-pre-message-hook' to ignore messages from
blocked users."
  (let ((sender-uid (plist-get msg :sender_user_id)))
    (when (and (not (zerop sender-uid))
               (plist-get
                (telega--full-info (telega-user--get sender-uid))
                :is_blocked))
      (telega-msg-ignore msg))))


(defun telega-msg-save (msg)
  "Save messages's MSG media content to a file."
  (interactive (list (telega-msg-at (point))))
  (let ((content (plist-get msg :content)))
    (cl-case (telega--tl-type content)
      (t (error "TODO: `telega-msg-save'")))))

(defun telega-describe-message (msg)
  "Show info about message at point."
  (interactive (list (telega-msg-at (point))))
  (with-telega-help-win "*Telegram Message Info*"
    (let ((chat-id (plist-get msg :chat_id))
          (msg-id (plist-get msg :id)))
      (telega-ins "Date(ISO8601): ")
      (telega-ins--date-iso8601 (plist-get msg :date) "\n")
      (telega-ins-fmt "Chat-id: %d\n" chat-id)
      (telega-ins-fmt "Message-id: %d\n" msg-id)
      (let ((sender-uid (plist-get msg :sender_user_id)))
        (unless (zerop sender-uid)
          (telega-ins "Sender: ")
          (insert-text-button (telega-user--name (telega-user--get sender-uid))
                              :telega-link (cons 'user sender-uid))
          (telega-ins "\n")))
      (when (telega-chat--public-p (telega-chat-get chat-id) 'supergroup)
        (let ((link (telega-msg-public-link msg)))
          (telega-ins "Link: ")
          (telega-ins--raw-button (telega-link-props 'url link)
            (telega-ins link))
          (telega-ins "\n")))

      (when telega-debug
        (telega-ins-fmt "MsgSexp: (telega-msg--get %d %d)\n" chat-id msg-id))

      (when telega-debug
        (telega-ins-fmt "\nMessage: %S\n" msg))
      )))

(defun telega-ignored-messages ()
  "Display all messages that has been ignored."
  (interactive)
  (with-help-window " *Telegram Ignored Messages*"
    (set-buffer standard-output)
    (dolist (msg (ring-elements telega--ignored-messages-ring))
      (telega-button--insert 'telega-msg msg
        :inserter 'telega-ins--message-ignored)
      (telega-ins "\n")
      )))

(provide 'telega-msg)

;;; telega-msg.el ends here
