;;; telega-customize.el --- Customization for telega  -*- lexical-binding:t -*-

;; Copyright (C) 2018 by Zajcev Evgeny.

;; Author: Zajcev Evgeny <zevlg@yandex.ru>
;; Created: Mon Apr 23 18:11:45 2018
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
(defgroup telega nil
  "Telegram client."
  :prefix "telega-"
  :group 'applications
  :link '(url-link :tag "Github" "https://github.com/zevlg/telega.el"))

(defcustom telega-directory (expand-file-name "~/.telega")
  "Directory for telega runtime files."
  :type 'string
  :group 'telega)

(defcustom telega-cache-dir (expand-file-name "cache" telega-directory)
  "*Directory for telegram downloads."
  :type 'string
  :group 'telega)

(defcustom telega-temp-dir (expand-file-name "temp" telega-directory)
  "*Directory for temporary files used by telega."
  :type 'string
  :group 'telega)

(defcustom telega-language "en"
  "*IETF language tag of the user's language."
  :type 'string
  :group 'telega)

(defcustom telega-options-plist
  (list :online t :localization_target "tdesktop")
  "*Plist of options to set.
To use custom language pack (from \"tdesktop\" localization target),
add `:language_pack_id' option.
Only writable options can be set.  See: https://core.telegram.org/tdlib/options"
  :type 'plist
  :group 'telega)

(defcustom telega-debug nil
  "*Non-nil to enable telega debugging buffer."
  :type 'boolean
  :group 'telega)

(defcustom telega-use-test-dc nil
  "*Non-nil to use telegram's test environment instead of production."
  :type 'bool
  :group 'telega)

(defcustom telega-use-file-database t
  "Non-nil to save downloaded/uploaded files among restarts."
  :type 'bool
  :group 'telega)

(defcustom telega-use-chat-info-database t
  "Cache chats informations among restarts.
Implies `telega-use-file-database' set to non-nil."
  :type 'bool
  :group 'telega)

(defcustom telega-use-message-database t
  "Cache chats and messages among restarts.
Implies `telega-use-chat-info-database' set to non-nil."
  :type 'bool
  :group 'telega)

(defcustom telega-proxies nil
  "*List of proxies.
Format is:
  (:server \"<SERVER>\" :port <PORT> :enable <BOOL> :type <PROXY-TYPE>)

where PROXY-TYPE is one of:
  (:@type \"proxyTypeSocks5\" :username <USER> :password <PASSWORD>)
  (:@type \"proxyTypeHttp\" :username <USER> :password <PASSWORD>
         :http_only <BOOL>)
  (:@type \"proxyTypeMtproto\" :secret <SECRET-STRING>)

<BOOL> is either t or `:false', nil is not valid value."
  :type 'list
  :group 'telega)

(defcustom telega-week-start-day 1
  "*The day of the week on which a week in the calendar begins.
0 means Sunday, 1 means Monday (default), and so on."
  :type 'integer
  :group 'telega)

(defcustom telega-week-day-names
  '("Sun" "Mon" "Tue" "Wed" "Thu" "Fri" "Sat")
  "*Week day names to use when printing times."
  :type 'list
  :group 'telega)

(defcustom telega-use-short-filenames t
  "*Non-nil to cut /home/user/.telega/cache from filenames."
  :type 'boolean
  :group 'telega)

(defcustom telega-use-tracking nil
  "*Non-nil to enable builtin tracking.el support.
Make sure you have tracking.el loaded if this option is enabled."
  :type 'boolean
  :group 'telega)

(defcustom telega-use-online-status t
  "*Non-nil to enable online status changes according to Emacs focus."
  :type 'boolean
  :group 'telega)

(defcustom telega-chat--display-buffer-action display-buffer--same-window-action
  "Action value when poping to chatbuffer.
See docstring for `display-buffer' for the values."
  :type 'cons
  :group 'telega)

(defcustom telega-emoji-fuzzy-match t
  "*Non-nil to use fuzzy prefix matching.
For example without fuzzy matches, prefix `:jo' will match only
`:joy:', `:joy-cat:' and `:joystick:'.  With fuzzy matching
enabled it will match alsy `:flag-jo:' and `:black-jocker:'."
  :type 'boolean
  :group 'telega)

(defcustom telega-emoji-custom-alist nil
  "*Alist of custom emojis to add along with `etc/emojis.alist'."
  :type 'alist
  :group 'telega)

(defcustom telega-sticker-size '(3 . 24)
  "*Size for the sticker.
car is height in chars to use.
cdr is maximum width in chars to use."
  :type 'cons
  :group 'telega)

(defcustom telega-sticker-favorite-background "cornflower blue"
  "*Background for the favorite stickers."
  :type 'string
  :group 'telega)

(defcustom telega-sticker-set-show-emoji nil
  "*Non-nil to show emoji along with sticker in sticker set help win."
  :type 'boolean
  :group 'telega)

(defcustom telega-animation-height 3
  "*Height of animations in char heights."
  :type 'integer
  :group 'telega)

(defcustom telega-animation-download-saved nil
  "*Non-nil to automatically download saved animations."
  :type 'boolean
  :group 'telega)

(defcustom telega-avatar-factors '(0.6 . 0.1)
  "*Factors for avatar generation.
car is factor for circle
cdr is factor for margin.
See `telega-avatar--create-img' for more info."
  :type 'cons
  :group 'telega)

(defcustom telega-vvnote-waves-height-factor 0.75
  "*Factor for waves svg height.
There is a restriction to its value:
`(* (frame-char-height) telega-vvnote-waves-height-factor)' must be > 8."
  :type 'float
  :group 'telega)

(defcustom telega-video-ffplay-args nil
  "*Additional arguments to ffplay to play video messages.
To play in fullscreen, set `telega-video-ffplay-args' to '(\"-fs\")."
  :type 'list
  :group 'telega)

(defcustom telega-location-url-format
  "http://maps.google.com/?q=%N,%E&ll=%N,%E&z=15"
  "*URL format used to open location messages.
%N substituted with lattitude.
%E substituted with longitude."
  :type 'string
  :group 'telega)

(defcustom telega-location-thumb-params (list 15 700 400 1)
  "*Parameters to `telega--getMapThumbnailFile' to generate location map."
  :type 'list
  :group 'telega)


(defgroup telega-server nil
  "Customisation for telega-server."
  :prefix "telega-server-"
  :group 'telega)

(defcustom telega-server-command "telega-server"
  "Command to run as telega server."
  :type 'string
  :group 'telega-server)

(defcustom telega-server-logfile
  (expand-file-name "telega-server.log" telega-directory)
  "*Write server logs to this file.
Set it to nil to disable telega-server logging."
  :type 'string
  :group 'telega-server)

(defcustom telega-server-verbosity 3
  "*Verbosity level for server process.
Verbosity levels are from 0 (disabled) to 5 (debug)."
  :type 'number
  :group 'telega-server)

(defcustom telega-server-call-timeout 1.0
  "*Timeout for `telega-server--call'."
  :type 'number
  :group 'telega-server)


(defgroup telega-root nil
  "Customization for telega-root-mode"
  :prefix "telega-root-"
  :group 'telega)

(defcustom telega-root-compact-view t
  "*Non-nil for compact view (no newline delims) in root buffer."
  :type 'boolean
  :group 'telega-root)

(defcustom telega-root-keep-cursor t
  "*Non-nil to keep cursor at current chat even if chat's order changes."
  :type 'boolean
  :group 'telega-root)

(defcustom telega-root-buffer-name "*Telega Root*"
  "*Buffer name for telega root buffer."
  :type 'string
  :group 'telega-root)

(defcustom telega-root-fill-column fill-column
  "*Maximum width to use in root buffer to display active filters and chats."
  :type 'integer
  :group 'telega-root)

(defcustom telega-chat-button-width 28
  "*Width for the chat buttons in root buffer.."
  :type 'integer
  :group 'telega-root)

(defcustom telega-chat-button-brackets
  '(((type private)    "{" "}")
    ((type basicgroup) "(" ")")
    ((type supergroup) "[" "]")
    ((type channel)    "<" ">")
    (all               "[" "]"))
  "Brackets to use for chat button."
  :type 'list
  :group 'telega-root)

(defcustom telega-chat-me-custom-title (propertize "Saved Messages" 'face 'bold)
  "*Custom title for the chat with myself.
Set it to nil to use your user name instead of default \"Saved Messages\"."
  :type 'string
  :group 'telega-root)

(defcustom telega-chat-label-format (propertize "%L | " 'face 'bold)
  "*Non-nil to prefix chat's title with custom label.
%L - replaced with chat's label.
See `telega-chat-custom-label' for details."
  :type 'string
  :group 'telega-root)

(defcustom telega-status-animate-interval 0.5
  "Dots animation interval for telega status shown in root buffer."
  :type 'number
  :group 'telega-root)


(defgroup telega-filter nil
  "Customize chats filtration."
  :prefix "telega-filter-"
  :group 'telega)

(defcustom telega-filter-default 'all
  "*Default chats filter to apply.
For example:
  `(any pin unread)'  - to show pinned or chats with unread messages."
  :type 'list
  :group 'telega-filter)

(defcustom telega-filters-custom
  '(("All" . all)
    ("Secrets" . (type secret))
    ("Bots" . (type bot))
    ("Groups" . (type basicgroup supergroup))
    ("Private" . (type private))
    ("Channels" . (type channel))
    ("Contacts" . (contact out))
    ("Notify" . notify)
    ("Unread" . unread))
  "*Alist of custom filters for chats.
In form (NAME . FILTER-SPEC)."
  :type 'alist
  :group 'telega-filter)

(defcustom telega-filter-custom-expand t
  "*Non-nil to expand custom filter when adding to active filters."
  :type 'boolean
  :group 'telega-filter)

(defcustom telega-filter-button-width 20
  "*Width of the custom filter buttons."
  :type 'integer
  :group 'telega-filter)


(defgroup telega-inserter nil
  "Group to customize inserters used by telega for formatting."
  :group 'telega
  :prefix "telega-inserter-")

(defcustom telega-inserter-for-filter-button 'telega-ins--filter
  "Inserter for the custom filter buttons."
  :type 'function
  :group 'telega-inserters)

(defcustom telega-inserter-for-chat-button 'telega-ins--chat-full
  "Inserter for the chat button in root buffer."
  :type 'function
  :group 'telega-inserters)

(defcustom telega-inserter-for-msg-button 'telega-ins--message
  "Inserter for message button in chat buffer.
Accepts at least two arguments - MSG and NO-HEADER-P.
See `telega-ins--message' for NO-HEADER argument."
  :type 'function
  :group 'telega-inserter)

(defcustom telega-inserter-for-msg-notification 'telega-ins--msg-notification
  "*Inserter used to form body for notification bubble."
  :type 'function
  :group 'telega-inserter)


(defgroup telega-webpage nil
  "Customization for instant view webpage rendering."
  :group 'telega)

(defcustom telega-webpage-fill-column fill-column
  "*Fill column to use for webpage rendering."
  :type 'integer
  :group 'telega-webpage)

(defcustom telega-webpage-history-max 100
  "*Maximum number of viewed webpages to remember in history."
  :type 'number
  :group 'telega-webpage)

(defcustom telega-webpage-header-line-format
  '(" " (:eval (concat telega-webpage--sitename
                       (and telega-webpage--sitename ": ")
                       telega-webpage--url
                       "  "
                       (format "History: %d/%d"
                               (1+ telega-webpage-history--index)
                               (length telega-webpage-history))
                       )))
  "Header line format for instant webpage."
  :type 'list
  :group 'telega-webpage)

(defcustom telega-webpage-photo-maxsize (cons telega-webpage-fill-column 20)
  "*Limit displayed image size to this (WIDTH . HEIGHT) characters."
  :type '(cons integer integer)
  :group 'telega-webpage)


(defgroup telega-user nil
  "Customization for users."
  :group 'telega)

(defcustom telega-user-use-avatars (image-type-available-p 'svg)
  "Non-nil to use avatars for the users."
  :type 'boolean
  :group 'telega-user)

(defcustom telega-user-photo-maxsize '(10 . 10)
  "*Limit displayed profile photos size to this (WIDTH . HEIGHT) characters."
  :type '(cons integer integer)
  :group 'telega-user)


(defgroup telega-chat nil
  "Customization for chat buffer."
  :group 'telega)

(defcustom telega-chat-input-prompt ">>> "
  "*Prompt for the chat buffers."
  :type 'string
  :group 'telega-chat)

(defcustom telega-chat-reply-prompt telega-chat-input-prompt
  "*Prompt to use when replying to message."
  :type 'string
  :group 'telega-chat)

(defcustom telega-chat-edit-prompt telega-chat-input-prompt
  "*Prompt to use when replying to message."
  :type 'string
  :group 'telega)

(defcustom telega-chat-fwd-prompt telega-chat-input-prompt
  "*Prompt to use when forwarding message."
  :type 'string
  :group 'telega)

(defcustom telega-chat-input-ring-size 50
  "*Size of the chat input history."
  :type 'integer
  :group 'telega-chat)

(defcustom telega-chat-fill-column fill-column
  "*Column to fill chat messages to."
  :type 'integer
  :group 'telega-chat)

(defcustom telega-chat-history-limit 20
  "Number of messages to fetch on history requests."
  :type 'integer
  :group 'telega-chat)

(defcustom telega-chat-insert-date-breaks t
  "*Non-nil to insert breaks inbetween messages of different days.
NOT YET IMPLEMENTED"
  :type 'boolean
  :group 'telega-chat)

(defcustom telega-chat-use-markdown-formatting nil
    "*Non-nil to use markdown formatting for outgoing messages."
  :type 'boolean
  :group 'telega-chat)

(defcustom telega-chat-upload-attaches-ahead t
  "*Non-nil to upload attachements ahead, before message actually sent.
Having this non-nil \"speedups\" uploading, its like files uploads instantly."
  :type 'boolean
  :group 'telega-chat)

(defcustom telega-chat-group-messages-for '(not (or saved-messages (type channel bot)))
  "*If this filter returns non-nil for chat, then messages groups by sender."
  :type 'list
  :group 'telega-chat)


;; VoIP
(defgroup telega-voip nil
  "VOIP settings."
  :group 'telega)

(defcustom telega-voip-allow-p2p nil
  "*Non-nil to allow P2P connections for calls."
  :type 'boolean
  :group 'telega-voip)

(defcustom telega-voip-busy-if-active t
  "*Reply with busy status to any incoming calls if have active call."
  :type 'boolean
  :group 'telega-voip)

(defcustom telega-voip-help-echo t
  "*Non-nil to show help messages in echo area on call activation."
  :type 'boolean
  :group 'telega-voip)

(defcustom telega-voip-use-sounds nil
  "*Non-nil to play sounds (using ffplay) for call status changes."
  :type 'boolean
  :group 'telega-voip)


;; Notifications
(defgroup telega-notifications nil
  "Setup for D-Bus notifications."
  :group 'telega)

(defcustom telega-notifications-delay 0.5
  "*Delay in seconds for notifications.
This delay is taken before making decision show or not the
message in notification.
Taking pause before showing notification is wise, because another
telegram may be active with the chat opened, you don't want the
notification to be shown for already read message.
Set it to 0, for no delay notifications."
  :type 'float
  :group 'telega-notifications)

(defcustom telega-notifications-timeout 4.0
  "*How long to show notification in seconds."
  :type 'float
  :group 'telega-notifications)

;; NOTE: standard values for :sound-name
;; http://0pointer.de/public/sound-naming-spec.html
(defcustom telega-notifications-msg-args
  (list :sound-name "message-new-instant")
  "*Additional arguments to `notifications-notify' on chat messages."
  :type 'list
  :group 'telega-notifications)

(defcustom telega-notifications-call-args
  (list :sound-name "phone-incoming-call")
  "*Additional arguments to `notifications-notify' on incoming calls."
  :type 'list
  :group 'telega-notifications)

;; See https://github.com/zevlg/telega.el/issues/32
(defcustom telega-notifications-msg-body-limit 100
  "*Limit for the message body length.
Used by `telega-ins--msg-notification'."
  :type 'integer
  :group 'telega-notifications)

(defcustom telega-notifications-defaults nil
  "Cons cell with notifications settings.
car for private/secret chats
cdr for any groups including channels
For example:
  (cons
    (list :mute_for 0 :show_preview t)
    (list :mute_for 599695961 :show_preview t))"
  :type 'cons
  :group 'telega-notifications)


(defgroup telega-msg nil
  "Customization for telega messages formatting."
  :prefix "telega-msg-"
  :group 'telega)

(defcustom telega-msg-show-sender-status nil
  "*Non-nil to show message sender status.
Such as admin, creator, etc
DO NOT USE.  TODO: sender statuses need to be cached."
  :type 'boolean
  :group 'telega-msg)

(defcustom telega-msg-rainbow-title t
  "*Non-nil to display user names in chatbuf with their assigned color."
  :type 'boolean
  :group 'telega-msg)

(defcustom telega-msg-heading-whole-line nil
  "*Non-nil to spread `telega-msg-heading' face to full line width.
Also applies to `telega-msg-inline-reply' face."
  :type 'boolean
  :group 'telega-msg)

(defcustom telega-msg-photo-types '("w" "d" "y" "c" "x" "b" "m" "s" "a")
  "*Size types to use for full size photos."
  :type 'list
  :group 'telega-msg)

(defcustom telega-msg-photo-slices 'auto
  "*Split photo into horisontal slices for better scrolling experience.
Integer or `auto'."
  :type 'integer
  :group 'telega-msg)

(defcustom telega-photo-maxsize '(40 . 10)
  "*Limit displayed image size to this (WIDTH . HEIGHT) characters."
  :type '(cons integer integer)
  :group 'telega)

(defcustom telega-photo-fill-char ?o
  "Char to use for filling image placement."
  :type 'char
  :group 'telega)

;; (defcustom telega-msg-photo-props
;;   '(:scale 1.0 :max-height 432 :max-width 960 :ascent 100)
;;   "*Properties to apply when image is created for the photos."
;;   :type 'plist
;;   :group 'telega-msg)

(defcustom telega-auto-download
  '((photo all)
    (video opened)
    (file opened)
    (voice-message opened)
    (video-message opened)
    (web-page opened)
    (instant-view opened))
  "*Alist in form (KIND . FILTER-SPEC).
To denote for which chats to automatically download media content.
KIND is one of `photo', `video', `file', `voice-message',
`video-message', `web-page', `instant-view'.
Used by `telega-msg-autodownload-media'."
  :type 'boolean
  :group 'telega)

(defcustom telega-ignored-messages-ring-size 100
  "*Maximum number of ignored messages in `telega--ignored-messages'.
Message is ignored if its `:ignore' option is set to non-nil."
  :type 'number
  :group 'telega-chat)

(defcustom telega-completing-read-function 'ido-completing-read
  "Completing read function to use."
  :type 'function
  :group 'telega)

;; special symbols
(defgroup telega-symbol nil
  "Group to customize special symbols used by telega."
  :group 'telega)

(defcustom telega-symbol-eliding "..."
  "*String used for eliding long string in formats.
Nice looking middle dots can be done by setting
`telega-symbol-eliding' to `(make-string 3 #x00b7)'
or set it to \"\\u2026\" or \"\\u22ef\" to use unicode char for
ellipsis."
  :type 'string
  :group 'telega-symbol)

(defcustom telega-symbol-eye "👁"        ;\U0001F441
  "String to use as eye symbol."
  :type 'string
  :group 'telega-symbol)

(defcustom telega-symbol-pin "📌"       ;\U0001F4CC
  "*String to use as pin symbol."
  :type 'string
  :group 'telega-symbol)

(defcustom telega-symbol-custom-order (cons "↓" "↑")
  "Symbols used to emphasize custom order for the chat.
car is used if custom order is less then real chat's order.
cdr is used if custom order is greater then real chat's order."
  :type 'cons
  :group 'telega-symbol)

(defcustom telega-symbol-lock "🔒"      ;\U0001F512
  "*String to use as lock symbol."
  :type 'string
  :group 'telega-symbol)

(defcustom telega-symbol-attachment "📎"  ;\U0001F4CE
  "*String to use as attachement symbol.
\"📄\" is also good candidate."
  :type 'string
  :group 'telega-symbol)

(defcustom telega-symbol-photo "📷"     ;\U0001F4F7
  "*String to use as photo symbol."
  :type 'string
  :group 'telega-symbol)

(defcustom telega-symbol-audio "🎶"     ;\U0001F3B6
  "*String to use as audio symbol."
  :type 'string
  :group 'telega-symbol)

(defcustom telega-symbol-video "📹"     ;\U0001F4F9
  "*String to use as video symbol."
  :type 'string
  :group 'telega-symbol)

(defcustom telega-symbol-game "🎮"      ;\U0001F3AE
  "*String to use as video game symbol."
  :type 'string
  :group 'telega-symbol)

(defcustom telega-symbol-pending "⌛"   ;\u231B
  "Symbol to use for pending outgoing messages."
  :type 'string
  :group 'telega-symbol)

(defcustom telega-symbol-checkmark "✓" ;\u2713
  "Symbol for simple check mark."
  :type 'string
  :group 'telega-symbol)

(defcustom telega-symbol-heavy-checkmark "✔" ;\u2714
  "Symbol for heavy check mark."
  :type 'string
  :group 'telega-symbol)

(defcustom telega-symbol-failed "⛔"    ;\u26D4
  "Mark messages that have sending state failed."
  :type 'string
  :group 'telega-symbol)

(defcustom telega-symbol-vertical-bar "|\u00A0"
  "Symbol used to form vertical lines."
  :type 'string
  :group 'telega-symbol)

(defcustom telega-symbol-underline-bar "_"
  "Symbol used to draw underline bar.
\"\uFF3F\" is also good candidate for underline bar."
  :type 'string
  :group 'telega-symbol)

(defcustom telega-symbol-draft (propertize "Draft" 'face 'error)
  "Symbol used for draft formatting."
  :type 'string
  :group 'telega-symbol)

(defcustom telega-symbol-unread "●"
  "Symbol used for chats marked as unread.
Good candidates also are 🄌 or ⬤."
  :type 'string
  :group 'telega-symbol)

(defcustom telega-symbol-verified (propertize "🅥" 'face 'telega-blue)
  "Symbol used to emphasize verified users/groups."
  :type 'string
  :group 'telega-symbol)

(defcustom telega-symbol-star (propertize "★" 'face 'error)
  "Symbol used to emphasize stared chats."
  :type 'string
  :group 'telega-symbol)

(defcustom telega-symbol-thunder "🗲"
  "Symbol used inside INSTANT VIEW buttons."
  :type 'string
  :group 'telega-symbol)

(defcustom telega-symbol-location "🌐"
  "Symbol used for location."
  :type 'string
  :group 'telega-symbol)

(defcustom telega-symbol-phone "📞"
  "Symbol used as phone."
  :type 'string
  :group 'telega-symbol)

(defcustom telega-symbol-square "■"
  "Symbol used for large squares."
  :type 'string
  :group 'telega-symbol)

(defcustom telega-symbol-ballout-empty "☐"
  "Symbol used for empty ballout."
  :type 'string
  :group 'telega-symbol)

(defcustom telega-symbol-ballout-check "☑"
  "Symbol used for checked ballout."
  :type 'string
  :group 'telega-symbol)

(defcustom telega-symbol-contact "🚹"
  "Symbol used for contacts."
  :type 'string
  :group 'telega-symbol)

(defcustom telega-symbol-play "▶"
  "Symbol used for playing."
  :type 'string
  :group 'telega-symbol)

(defcustom telega-symbol-pause "⏸"
  "Symbol used for pause."
  :type 'string
  :group 'telega-symbol)

(defcustom telega-symbol-invoice "🛒"
  "Symbol used in invoice messages."
  :type 'string
  :group 'telega-symbol)

(defcustom telega-symbol-poll "📊"
  "Symbol used in poll messages."
  :type 'string
  :group 'telega-symbol)

(defcustom telega-symbol-poll-options (cons "○" "●")
  "Symbols used to display poll options.
car is for non-selected option, cdr is for selected option."
  :type 'cons
  :group 'telega-symbol)

(defcustom telega-symbol-attach-brackets (cons "⟬" "⟭")
  "Symbols used to emphasize attachement in chat buffer input."
  :type 'cons
  :group 'telega-symbol)

(defcustom telega-symbol-webpage-details (cons "▼" "▲")
  "Symbols used to display `pageBlockDetails' webpage block."
  :type 'cons
  :group 'telega-symbol)

(defcustom telega-symbol-online-status (propertize "*" 'face 'success)
  "Symbol used to display user's online status in root buffer.
If nil, then user's online status is not displayed."
  :type 'string-or-null-p
  :group 'telega-symbol)

(defcustom telega-symbol-widths
  (list
   (list 1
         telega-symbol-contact)
   (list 2
         telega-symbol-eye
         telega-symbol-unread
         telega-symbol-verified
         telega-symbol-thunder

         telega-symbol-checkmark
         telega-symbol-heavy-checkmark
         telega-symbol-ballout-empty
         telega-symbol-ballout-check

         telega-symbol-play
         (car telega-symbol-poll-options)
         (cdr telega-symbol-poll-options)
         ))
  "*Custom widths for some symbols, used for correct formatting.
Use `telega-symbol-set-width' to install symbol's width.
Install all symbol widths inside `telega-load-hook'."
  :type 'list
  :group 'telega-symbol)


;;; Faces
(defgroup telega-faces nil
  "Group to customize faces used by telega."
  :group 'telega)

(defface telega-link
  '((t :inherit link :underline nil))
  "Face to display various links."
  :group 'telega-faces)

(defface telega-button
  '((((class color) (min-colors 88) (background light))
     :foreground "RoyalBlue3"
     :box (:line-width -2 :color "RoyalBlue3" :style nil))
    (((class color) (min-colors 88) (background dark))
     :foreground "cyan1"
     :box (:line-width -2 :color "cyan1" :style nil))
    (t :inherit highlight))
  "Face used for telega buttons."
  :group 'telega-faces)

(defface telega-button-active
  '((((class color) (min-colors 88) (background light))
     :inherit telega-button
     :foreground "white" :background "RoyalBlue3")
    (((class color) (min-colors 88) (background dark))
     :foreground "white" :background "cyan1"
     :inherit telega-button)
    (t :inherit telega-button))
  "Face used for active (cursor inside) telega buttons."
  :group 'telega-faces)

(defface telega-box
  '((((class color) (min-colors 88) (background light))
     :inherit default
     :box (:line-width -2 :color "gray30" :style nil))
    (((class color) (min-colors 88) (background dark))
     :inherit default
     :box (:line-width -2 :color "gray70" :style nil)))
  "Face used to outline boxes."
  :group 'telega-faces)

(defface telega-blue
  '((t :inherit default :foreground "#2ca5e0"))
  "*Official blue color of telegram."
  :group 'telega-faces)

(defface telega-enckey-00
  '((t :inherit default :foreground "#ffffff" :background "#ffffff"))
  "Face used for encryption key"
  :group 'telega-faces)

(defface telega-enckey-01
  '((t :inherit default :foreground "#d5e6f3" :background "#d5e6f3"))
  "Face used for encryption key"
  :group 'telega-faces)

(defface telega-enckey-10
  '((t :inherit default :foreground "#2d5775" :background "#2d5775"))
  "Face used for encryption key"
  :group 'telega-faces)

(defface telega-enckey-11
  '((t :inherit default :foreground "#2f99c9" :background "#2f99c9"))
  "Face used for encryption key"
  :group 'telega-faces)

(defface telega-filter-button-active
  '((t :inherit default))
  "*Face to use for active custom filters."
  :group 'telega-faces)

(defface telega-filter-button-inactive
  '((t :inherit shadow))
  "*Face to use for inactive custom filters."
  :group 'telega-faces)

(defface telega-filter-active
  '((t :inherit bold))
  "Face to emphasize active chat filter other then `telega-filter-default'."
  :group 'telega-faces)

(defface telega-root-heading
  '((((background light))
     :background "light gray" :foreground "dim gray")
    (((background dark))
     :background "dim gray" :foreground "light gray"))
  "Face used to display headings, such as GLOBAL SEARCH, in root buffer."
  :group 'telega-faces)

(defface telega-chat-prompt
  '((t (:inherit default :weight bold)))
  "Face for chat input prompt"
  :group 'telega-faces)

(defface telega-chat-input-attachment
  '((t (:inherit bold)))
  "Face for chat input attachements."
  :group 'telega-faces)

(defface telega-unread-unmuted-modeline
  '((t :inherit error))
  "Face used to display number of unread/unmuted messages in modeline."
  :group 'telega-faces)

(defface telega-muted-count
  `((t :inherit shadow))
  "Face to display count of messages in muted chats."
  :group 'telega-faces)

(defface telega-unmuted-count
  '((t :inherit default :foreground "blue"))
  "Face to display count messages in unmuted chats."
  :group 'telega-faces)

(defface telega-mention-count
  '((t :weight bold :foreground "blue"))
  "Face to display count of the mentions."
  :group 'telega-faces)

(defface telega-username
  '((((class color)
      (background dark))
     :foreground "DodgerBlue")
    (((class color)
      (background light))
     :foreground "RoyalBlue")
    (t :bold t))
  "Face to display username for chats/users."
  :group 'telega-faces)

(defface telega-entity-type-mention
  '((t :inherit telega-username))
  "Face to display @mentions."
  :group 'telega-faces)

(defface telega-entity-type-hashtag
  '((t :inherit telega-link))
  "Face to display #hashtags."
  :group 'telega-faces)

(defface telega-entity-type-cashtag
  '((t :inherit default :foreground "blue"))
  "Face to display $USD cashtags"
  :group 'telega-faces)

(defface telega-entity-type-botcommand
  '((t :inherit default :foreground "blue"))
  "Face to display /command if there is bot in chat."
  :group 'telega-faces)

(defface telega-entity-type-bold
  '((t :inherit bold))
  "Face to display bold text."
  :group 'telega-faces)

(defface telega-entity-type-italic
  '((t :inherit italic))
  "Face to display italic text."
  :group 'telega-faces)

(defface telega-entity-type-code
  '((t :family "Monospace Serif"))
  "Face to display code.
You can customize its `:height' to fit width of the default face.
Use `(set-face-attribute 'telega-entity-type-code nil :height 0.83333333)'"
  :group 'telega-faces)

(defface telega-entity-type-pre
  '((t :family "Monospace Serif"))
  "Face to display text ala <pre> HTML tag.
You can customize its `:height' to fit width of the default face."
  :group 'telega-faces)

(defface telega-entity-type-texturl
  '((t :inherit button))
  "Face to display urls."
  :group 'telega-faces)

(defface telega-secret-title
  '((t :foreground "#00b12c"))
  "Face to display title of secret chat in root buffer."
  :group 'telega-faces)

(defface telega-msg-heading
  '((t :inherit 'widget-field))
  "Face to display messages header."
  :group 'telega-faces)

(defface telega-msg-self-title
  '((t :bold t))
  "Face to display title of myself in chat buffers."
  :group 'telega-faces)

(defface telega-msg-user-title
  '((t nil))
  "Face to display user title in chat buffers."
  :group 'telega-faces)

(defface telega-msg-inline-reply
  '((t :inherit 'telega-msg-heading))
  "Face to highlight replies to messages."
  :group 'telega-faces)

(defface telega-msg-inline-forward
  '((t :inherit 'telega-msg-heading))
  "Face to highlight message forwarding header."
  :group 'telega-faces)

(defface telega-msg-outgoing-status
  '((t :height 0.8))
  "Face used to display message outgoing status symbol."
  :group 'telega-faces)

(defface telega-webpage-chat-link
  '((t :background "gray85"))
  "Face to display `pageBlockChatLink' web page blocks"
  :group 'telega-faces)

(defface telega-webpage-sitename
  '((t :inherit telega-link :bold t))
  "Face to display webpage's site_name."
  :group 'telega-faces)

(defface telega-webpage-title
  '((t :inherit bold))
  "Face to display webpage's title."
  :group 'telega-faces)

(defface telega-webpage-strike-through
  '((t :strike-through t))
  "Face to display strike through RichText."
  :group 'telega-faces)

(defface telega-webpage-header
  '((t :family "Georgia" :height 1.2))
  "Face to display header in webpage instant view."
  :group 'telega-faces)

(defface telega-webpage-subheader
  '((t :inherit telega-webpage-header :height 1.1))
  "Face to display subheader in webpage instant view."
  :group 'telega-faces)

(defface telega-webpage-fixed
  '((t :family "Monospace Serif" :height 0.85))
  "Face to display fixed text in webpage instant view."
  :group 'telega-faces)

(defface telega-webpage-preformatted
  '((t :inherit telega-webpage-fixed :background "gray85"))
  "Face to display preformatted text in webpage instant view."
  :group 'telega-faces)

(defface telega-user-online-status
  '((((class color)
      (background dark))
     :foreground "green")
    (((class color)
      (background light))
     :foreground "cornflower blue")
    (t :bold t))
  "Face to display user status if online."
  :group 'telega-faces)

(defface telega-user-non-online-status
  '((t :inherit shadow))
  "Face to display user status if non-online."
  :group 'telega-faces)

(defface telega-delim-face
  '((t :inherit shadow :height 0.5))
  "Face used to display horizontal delimiters."
  :group 'telega-faces)


(defgroup telega-hooks nil
  "Group to customize hooks used by telega."
  :group 'telega)

(defcustom telega-load-hook nil
  "Hooks run when telega is loaded."
  :type 'hook
  :group 'telega-hooks)

(defcustom telega-root-mode-hook nil
  "Hook run when telega root buffer is created."
  :type 'hook
  :group 'telega-hooks)

(defcustom telega-ready-hook nil
  "Hook called when telega is ready to process queries."
  :type 'hook
  :group 'telega-hooks)

(defcustom telega-closed-hook nil
  "Hook called when telega exited."
  :type 'hook
  :group 'telega-hooks)

(defcustom telega-connection-state-hook nil
  "Hook called when connection state changes."
  :type 'hook
  :group 'telega-hooks)

(defcustom telega-chats-fetched-hook nil
  "Hook called when all chats list has been fetched."
  :type 'hook
  :group 'telega-hooks)

(defcustom telega-chat-update-hook nil
  "Hook called with single argument CHAT, when CHAT updates."
  :type 'hook
  :group 'telega-hooks)

(defcustom telega-user-update-hook nil
  "Hook called with single argument USER, when USER's info is updated."
  :type 'hook
  :options '(telega-media--autodownload-on-user)
  :group 'telega-hooks)

(defcustom telega-chat-created-hook nil
  "Hook called when new chat has been loaded/created.
Called with one argument - chat."
  :type 'hook
  :options '(telega-media--autodownload-on-chat)
  :group 'telega-hooks)

(defcustom telega-chat-pre-message-hook nil
  "Hook called uppon new message arrival, before inserting into chatbuffer.
Called with single argument - MESSAGE.
Always called, even if corresponding chat is closed at the moment.
This hook can be used to ignore message, see
https://github.com/zevlg/telega.el#configuring-client-side-messages-filtering."
  :type 'hook
  :options '(telega-media--autodownload-on-msg)
  :group 'telega-hooks)

(defcustom telega-chat-post-message-hook nil
  "Hook called when new message has been inserted into chatbuffer.
Called with single argument - MESSAGE.
Always called, even if corresponding chat is closed at the moment.
Called even for messages ignored by client side filtering, to
check message is filtered by client side filtering use
`telega-msg-ignored-p'."
  :type 'hook
  :group 'telega-hooks)

(defcustom telega-call-incoming-hook nil
  "Hook called when incoming call pending.
Called with single argument - incoming call.
Use `telega-voip-active-call-p' to understand if call is currently active."
  :type 'hook
  :group 'telega-hooks)

(defcustom telega-call-outgoing-hook nil
  "Hook called when outgoing call is made.
Called with single argument - outgoing call."
  :type 'hook
  :group 'telega-hooks)

(defcustom telega-call-ready-hook nil
  "Hook called when call is ready.
Called with single argument - the call."
  :type 'hook
  :group 'telega-hooks)

(defcustom telega-call-end-hook nil
  "Hook called when call is ended.
Called with single argument - the call.
To find out call state examine the `:state' value."
  :type 'hook
  :group 'telega-hooks)

(provide 'telega-customize)

;;; telega-customize.el ends here
