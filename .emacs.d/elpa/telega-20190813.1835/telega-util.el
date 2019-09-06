;;; telega-util.el --- Utility functions for telega  -*- lexical-binding:t -*-

;; Copyright (C) 2018 by Zajcev Evgeny.

;; Author: Zajcev Evgeny <zevlg@yandex.ru>
;; Created: Sat Apr 21 03:56:02 2018
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

;; Utility functions to be used by telega

;;; Code:

(require 'ewoc)
(require 'cl-lib)
(require 'files)                        ; `locate-file'
(require 'rx)                           ; `rx'
(require 'svg)
(require 'color)                        ; `color-XXX'

(require 'telega-customize)

(declare-function telega-root--buffer "telega-root")
(declare-function telega-chat-title "telega-chat")
(declare-function telega-browse-url "telega-webpage" (url &optional in-web-browser))

(defun telega-file-exists-p (filename)
  "Return non-nil if FILENAME exists.
Unlike `file-exists-p' this return nil for empty string FILENAME.
Also return `nil' if FILENAME is `nil'."
  (and filename
       (not (string-empty-p filename))
       (file-exists-p filename)))

(defsubst telega-plist-del (plist prop)
  "From PLIST remove property PROP."
  (cl--plist-remove plist (plist-member plist prop)))

(defun telega-face-height (face)
  "Return float version of FACE height."
  (let ((height (face-attribute face :height)))
    (if (floatp height)
        height
      (/ (float height) (face-attribute 'default :height)))))

(defun telega-short-filename (filename)
  "Shortens FILENAME by removing `telega-directory' prefix."
  (if (and telega-use-short-filenames
           (string-prefix-p (concat telega-directory "/") filename))
      (substring filename (1+ (length telega-directory)))
    (abbreviate-file-name filename)))

(defun telega-x-frame ()
  "Return window system frame, if any.
Selected frame and frame displaying root buffer are examined first."
  (cl-find-if (lambda (frame)
                (frame-parameter frame 'window-system))
              (nconc (list (selected-frame)
                           (window-frame
                            (get-buffer-window (telega-root--buffer))))
                     (frame-list))))

(defun telega-chars-width (n)
  "Return pixel width for N characters"
  (* (frame-char-width (telega-x-frame)) n))

(defun telega-chars-in-height (pixels)
  "Return how many lines needed to cover PIXELS height."
  (ceiling (/ pixels (float (frame-char-height (telega-x-frame))))))

(defun telega-chars-in-width (pixels)
  "Return how many characters needed to cover PIXELS width."
  (ceiling (/ pixels (float (frame-char-width (telega-x-frame))))))

(defun telega-strip-newlines (string)
  "Strip STRING newlines from end and beginning."
  (replace-regexp-in-string
   (rx (or (: string-start (* (any ?\r ?\n)))
           (: (* (any ?\r ?\n)) string-end)))
   ""
   string))

(defun telega-current-column ()
  "Same as `current-column', but take into account width of the characters."
  (string-width (buffer-substring (point-at-bol) (point))))

(defsubst telega-color-to-hex (col)
  (color-rgb-to-hex (car col) (cadr col) (caddr col) 2))

(defun telega-color-random (&optional lightness)
  "Generates random color with lightness below LIGHTNESS.
Default LIGHTNESS is 0.85."
  (telega-color-to-hex
   (color-hsl-to-rgb (cl-random 1.0) (cl-random 1.0)
                     (cl-random (or lightness 0.85)))))

(defun telega-color-gradient (color &optional light)
  "For given color return its darker version.
Used to create gradients.
If LIGHT is non-nil then return lighter version."
  (telega-color-to-hex
   (mapcar (lambda (c) (if light (color-clamp (* c 1.5)) (/ c 2)))
           (color-name-to-rgb color))))

(defun telega-color-tripple (col)
  "Return color COL tripple in form (LIGHT-COL COL DARK-COL)."
  (list (telega-color-gradient col 'light)
        col
        (telega-color-gradient col)))

(defun telega-temp-name (prefix &optional ext)
  "Generate unique temporary file name with PREFIX and extension EXT.
Specify EXT with leading `.'."
  (concat (expand-file-name (make-temp-name prefix) telega-temp-dir) ext))

(defun telega-svg-clip-path (svg id)
  (let ((cp (dom-node 'clipPath `((id . ,id)))))
    (svg--def svg cp)
    cp))

(defun telega-svg-path (svg d &rest args)
  (svg--append svg (dom-node 'path
                             `((d . ,d)
                               ,@(svg--arguments svg args)))))

(defun telega-svg-progress (svg progress)
  "Insert progress circle into SVG."
  (let* ((w (alist-get 'width (cadr svg)))
         (h (alist-get 'height (cadr svg)))
         ;; progress clipping mask
         (angle-o (+ pi (* 2 pi (- 1.0 progress))))
         (clip-dx (* (/ w 2) (1+ (sin angle-o))))
         (clip-dy (* (/ h 2) (1+ (cos angle-o))))
         (pclip (telega-svg-clip-path svg "pclip")))
    ;; clip mask for the progress circle
    (let ((cp (format "M %d %d L %d %d L %d 0" (/ w 2) (/ h 2) (/ w 2) 0 0)))
      (when (< progress 0.75)
        (setq cp (concat cp (format " L 0 %d" h))))
      (when (< progress 0.5)
        (setq cp (concat cp (format " L %d %d" w h))))
      (when (< progress 0.25)
        (setq cp (concat cp (format " L %d 0" w))))
      (setq cp (concat cp (format " L %d %d" clip-dx clip-dy)))
      (setq cp (concat cp " Z"))
      (telega-svg-path pclip cp))
    ;; progress circle
    (svg-circle svg (/ w 2) (/ h 2) (/ h 2)
                :fill-color (face-foreground 'shadow)
                :fill-opacity "0.25"
                :clip-path "url(#pclip)")
    svg))

;; code taken from
;; https://emacs.stackexchange.com/questions/14420/how-can-i-fix-incorrect-character-width
(defun telega-symbol-widths-install (symbol-widths-alist)
  "Add symbol widths from SYMBOL-WIDTHS-ALIST to `char-width-table'.
Use it if you have formatting issues."
  (while (char-table-parent char-width-table)
    (setq char-width-table (char-table-parent char-width-table)))
  (dolist (pair symbol-widths-alist)
    (let ((width (car pair))
          (symbols (cdr pair))
          (table (make-char-table nil)))
      (dolist (symbol-str symbols)
        (set-char-table-range table (string-to-char symbol-str) width))
      (optimize-char-table table)
      (set-char-table-parent table char-width-table)
      (setq char-width-table table))))

(defun telega-symbol-set-width (symbol width)
  "Declare that SYMBOL's width is equal to WIDTH."
  (setf (alist-get width telega-symbol-widths)
        (cons symbol (alist-get width telega-symbol-widths))))

(defun telega-time-seconds ()
  "Return current time as unix timestamp."
  (floor (time-to-seconds)))

(defun telega-duration-human-readable (seconds &optional n)
  "Convert SECONDS to human readable string.
If N is given, then use only N significant components.
For example if duration is 4h:20m:3s then with N=2 4H:20m will be returned.
By default N=3 (all components).
N can't be 0."
  (cl-assert (or (null n) (> n 0)))
  (let ((ncomponents (or n 3))
        comps)
    (when (>= seconds 3600)
      (setq comps (list (format "%dh" (/ seconds 3600)))
            seconds (% seconds 3600)
            ncomponents (1- ncomponents)))
    (when (and (> ncomponents 0) (>= seconds 60))
      (setq comps (nconc comps (list (format "%dm" (/ seconds 60))))
            seconds (% seconds 60)
            ncomponents (1- ncomponents)))
    (when (and (> ncomponents 0) (or (null comps) (> seconds 0)))
      (setq comps (nconc comps (list (format "%ds" seconds)))))
    (mapconcat #'identity comps ":")))

(defun telega-etc-file (filename)
  "Return absolute path to FILENAME from etc/ directory in telega."
  (expand-file-name (concat "etc/" filename) telega--lib-directory))

(defun telega-link-props (link-type link-to &optional face)
  "Generate props for link button openable with `telega-link--button-action'."
  (cl-assert (memq link-type '(url file username user hashtag)))

  (list 'action 'telega-link--button-action
        'face (or face 'telega-link)
        :telega-link (cons link-type link-to)))

(defun telega-link--button-action (button)
  "Browse url at point."
  (let ((link (button-get button :telega-link)))
    (telega-debug "Action on link: %S" link)
    (cl-ecase (car link)
      (user (telega-describe-user (telega-user--get (cdr link))))
      (username
       (let ((user (telega-user--by-username (cdr link))))
         (if user
             (telega-describe-user user)
           (message (format "Fetching info about %s" (cdr link)))
           (telega--searchPublicChat (cdr link)
             (lambda (chat)
               (if (eq (telega-chat--type chat 'no-interpret)
                       'private)
                   (telega-describe-user
                    (telega-user--get (plist-get chat :id)))
                 (telega-describe-chat chat)))))))
      (hashtag
       (message "TODO: `hashtag' button action: tag=%s" (cdr link)))
      (url
       (telega-browse-url (cdr link)))
      (file (find-file (cdr link)))
      )))

(defun telega--entity-to-properties (entity text)
  "Convert telegram ENTITY to emacs text properties to apply to TEXT."
  (let ((ent-type (plist-get entity :type)))
    (cl-case (telega--tl-type ent-type)
      (textEntityTypeMention
       (telega-link-props 'username text
                          'telega-entity-type-mention))
      (textEntityTypeMentionName
       (telega-link-props 'user (plist-get ent-type :user_id)
                          'telega-entity-type-mention))
      (textEntityTypeHashtag
       (telega-link-props 'hashtag text))
      (textEntityTypeBold
       (list 'face 'telega-entity-type-bold))
      (textEntityTypeItalic
       (list 'face 'telega-entity-type-italic))
      (textEntityTypeCode
       (list 'face 'telega-entity-type-code))
      (textEntityTypePre
       (list 'face 'telega-entity-type-pre))
      (textEntityTypePreCode
       (list 'face 'telega-entity-type-pre))

      (textEntityTypeUrl
       (telega-link-props 'url text 'telega-entity-type-texturl))
      (textEntityTypeTextUrl
       (telega-link-props 'url (plist-get ent-type :url)
                          'telega-entity-type-texturl))
      )))

;; https://core.telegram.org/bots/api#markdown-style
(defun telega--entity-to-markdown (entity text)
  "Convert ENTITY back to markdown syntax applied to TEXT.
Return now text with markdown syntax."
  (let ((ent-type (plist-get entity :type)))
    (cl-case (and ent-type (telega--tl-type ent-type))
      (textEntityTypeBold (concat "*" text "*"))
      (textEntityTypeItalic (concat "_" text "_"))
      (textEntityTypeCode (concat "`" text "`"))
      ((textEntityTypePreCode textEntityTypePre)
       (concat "```" (plist-get ent-type :language) "\n" text "```"))
      (textEntityTypeMentionName
       (format "[%s](tg://user?id=%d)"
               text (plist-get ent-type :user_id)))
      (textEntityTypeTextUrl
       (format "[%s](%s)" text (plist-get ent-type :url)))
      (t text))))

(defun telega--entities-as-markdown (entities text)
  "Convert propertiezed TEXT to markdown syntax text.
Use `telega-entity-type-XXX' faces as triggers."
  (let ((offset 0) (strings nil))
    (seq-doseq (ent entities)
      (let ((ent-off (plist-get ent :offset))
            (ent-len (plist-get ent :length)))
        ;; Part without attached entity
        (when (> ent-off offset)
          (push (list nil (substring text offset ent-off)) strings))

        (setq offset (+ ent-off ent-len))
        (push (list ent (substring text ent-off offset)) strings)))
    ;; Trailing part, may be empty
    (push (list nil (substring text offset)) strings)

    (mapconcat 'substring-no-properties
               (mapcar (lambda (et)
                         (apply 'telega--entity-to-markdown et))
                       (nreverse strings))
               "")))

(defun telega--entities-as-faces (entities text)
  "Apply telegram ENTITIES to TEXT.
If AS-MARKDOWN is non-nil, then apply markdown syntax, instead of faces."
  (mapc (lambda (ent)
          (let* ((beg (plist-get ent :offset))
                 (end (+ (plist-get ent :offset) (plist-get ent :length)))
                 (props (telega--entity-to-properties
                         ent (substring-no-properties text beg end))))
            (when props
              (add-text-properties
               beg end (nconc (list 'rear-nonsticky t) props) text))))
        entities)
  text)

(defun telega--region-by-text-prop (beg prop)
  "Return region after BEG point with text property PROP set."
  (unless (get-text-property beg prop)
    (setq beg (next-single-char-property-change beg prop)))
  (let ((end (next-single-char-property-change beg prop)))
    (when (> end beg)
      (cons beg end))))

(defun telega--split-by-text-prop (string prop)
  "Split STRING by property PROP changes."
  (let ((start 0) end result)
    (while (and (> (length string) start)
                (setq end (next-single-char-property-change start prop string)))
      (push (substring string start end) result)
      (setq start end))
    (nreverse result)))

(defun telega--region-with-cursor-sensor (pos)
  "Locate region of the button with `cursor-sensor-functions' set.
Return `nil' if there is no button with `cursor-sensor-functions' at POS."
  (when (get-text-property pos 'cursor-sensor-functions)
    (let ((prev (previous-single-property-change pos 'cursor-sensor-functions)))
      (when (and prev (get-text-property prev 'cursor-sensor-functions))
        (setq pos prev))
      (telega--region-by-text-prop pos 'cursor-sensor-functions))))

;; NOTE: ivy returns copy of the string given in choices, thats why we
;; need to use 'string= as testfun in `alist-get'
(defun telega-completing-read-chat (prompt &optional only-filtered)
  "Read chat by title."
  (let ((choices (mapcar (lambda (chat)
                           (list (telega-chat-title chat 'with-username)
                                 chat))
                         (telega-filter-chats (and (not only-filtered) 'all)
                                              telega--ordered-chats))))
    (car (alist-get (funcall telega-completing-read-function
                             prompt choices nil t)
                    choices nil nil 'string=))))

(defun telega-completing-read-user (prompt)
  "Read user by his name."
  (let ((choices (mapcar (lambda (user)
                           (list (telega-user--name user)
                                 user))
                         (hash-table-values (alist-get 'user telega--info)))))
    (car (alist-get (funcall telega-completing-read-function
                             prompt choices nil t)
                    choices nil nil 'string=))))

(defun telega-completing-titles ()
  "Return list of titles ready for completing.
KIND is one of `chats', `users' or nil."
  (let ((result))
    (dolist (chat (telega-filter-chats 'all telega--ordered-chats))
      (setq result (cl-pushnew (telega-chat-title chat 'with-username) result
                               :test #'string=)))
    (dolist (user (hash-table-values (alist-get 'user telega--info)))
      (setq result (cl-pushnew (telega-user--name user) result
                               :test #'string=)))
    (nreverse result)))

(defun telega--animate-dots (text)
  "Animate TEXT's trailing dots.
Return `nil' if there is nothing to animate and new string otherwise."
  (when (string-match "\\.+$" text)
    (concat (substring text nil (match-beginning 0))
            (make-string
             (1+ (% (- (match-end 0) (match-beginning 0)) 3)) ?.))))


;; ewoc stuff
(defun telega-ewoc--gen-pp (pp-fun)
  "Wrap pretty printer function PP-FUN trapping all errors.
Do not trap errors if `debug-on-error' is enabled."
  (lambda (arg)
    (condition-case-unless-debug pp-err
        (funcall pp-fun arg)
      (t
       (telega-debug "PP-ERROR: (%S %S) ==>\n" pp-fun arg)
       (telega-debug "    %S\n" pp-err)
       (telega-debug "--------\n")

       (telega-ins "---[telega bug]\n")
       (telega-ins-fmt "PP-ERROR: (%S %S) ==>\n" pp-fun arg)
       (telega-ins-fmt "  %S\n" pp-err)
       (telega-ins "------\n")))))

(defun telega-ewoc--location (ewoc)
  "Return EWOC's start location."
  (ewoc-location (ewoc--header ewoc)))

(defun telega-ewoc--find (ewoc item test &optional key start-node)
  "Find EWOC's node by item and TEST funcion.
TEST function is run with two arguments - ITEM and NODE-VALUE.
Optionally KEY can be specified to get KEY from node value.
START-NODE is node to start from, default is first node."
  (ewoc--set-buffer-bind-dll-let* ewoc
      ((node (or start-node (ewoc--node-nth dll 1)))
       (footer (ewoc--footer ewoc))
       (inhibit-read-only t))
    (cl-block 'ewoc-node-found
      (while (not (eq node footer))
        (when (funcall test item (if key
                                     (funcall key (ewoc--node-data node))
                                   (ewoc--node-data node)))
          (cl-return-from 'ewoc-node-found node))
        (setq node (ewoc--node-next dll node))))))

(defun telega-ewoc--find-if (ewoc predicate &optional key start-node)
  "Find EWOC's node by PREDICATE run on node's data."
  (telega-ewoc--find
   ewoc nil (lambda (_ignored node-value)
              (funcall predicate node-value))
   key start-node))

(defmacro telega-ewoc--find-by-data (ewoc data)
  `(telega-ewoc--find ,ewoc ,data 'eq))

(defun telega-ewoc--set-header (ewoc header)
  "Set EWOC's new HEADER."
  ;; NOTE: No ewoc API to change just header :(
  ;; only `ewoc-set-hf'
  (ewoc--set-buffer-bind-dll-let* ewoc
      ((head (ewoc--header ewoc))
       (hf-pp (ewoc--hf-pp ewoc)))
    (setf (ewoc--node-data head) header)
    (ewoc--refresh-node hf-pp head dll)))

(defun telega-ewoc--set-footer (ewoc footer)
  "Set EWOC's new FOOTER."
  ;; NOTE: No ewoc API to change just footer :(
  ;; only `ewoc-set-hf'
  (ewoc--set-buffer-bind-dll-let* ewoc
      ((foot (ewoc--footer ewoc))
       (hf-pp (ewoc--hf-pp ewoc)))
    (setf (ewoc--node-data foot) footer)
    (ewoc--refresh-node hf-pp foot dll)))

(defun telega-ewoc--set-pp (ewoc pretty-printer)
  "Set EWOC's pretty printer to PRETTY-PRINTER.
Does NOT refreshes the contents, use `ewoc-refresh' to refresh."
  (setf (ewoc--pretty-printer ewoc) pretty-printer))

(defun telega-ewoc--clean (ewoc)
  "Delete all nodes from EWOC.
Header and Footer are not deleted."
  (ewoc-filter ewoc 'ignore))

(defun telega-ewoc--empty-p (ewoc)
  "Return non-nil if there is no visible EWOC nodes."
  (let ((n0 (ewoc-nth ewoc 0)))
    (or (null n0)
        (= (ewoc-location (ewoc-nth ewoc 0))
           (ewoc-location (ewoc--footer ewoc))))))


;; Emoji
(defvar telega-emoji-alist nil)
(defvar telega-emoji-candidates nil)
(defvar telega-emoji-max-length 0)

(defun telega-emoji-init ()
  "Initialize emojis."
  (unless telega-emoji-alist
    (setq telega-emoji-alist
          (nconc (with-temp-buffer
                   (insert-file-contents (telega-etc-file "emojis.alist"))
                   (goto-char (point-min))
                   (read (current-buffer)))
                 telega-emoji-custom-alist))
    (setq telega-emoji-candidates (mapcar 'car telega-emoji-alist))
    (setq telega-emoji-max-length
          (apply 'max (mapcar 'length telega-emoji-candidates)))))

(defun telega-emoji-name (emoji)
  "Find EMOJI name."
  (telega-emoji-init)
  (car (cl-find emoji telega-emoji-alist :test 'string= :key 'cdr)))

(provide 'telega-util)

;;; telega-util.el ends here
