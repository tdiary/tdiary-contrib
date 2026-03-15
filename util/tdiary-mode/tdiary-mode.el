;;; tdiary-mode.el --- Major mode for tDiary editing -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2002 Junichiro Kita
;;               2019-2026 Youhei SASAKI
;; Author: Junichiro Kita <kita@kitaj.no-ip.com>
;;         Youhei SASAKI <uwabami@gfd-dennou.org>
;; Version: 0.0.3
;; Keywords: comm
;; License: GPL-2.0+
;; Homepage: https://github.com/tdiary-contrib/util/tdiary-mode
;;
;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation; either version 2, or (at
;; your option) any later version.
;;
;; This program is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 59 Temple Place - Suite 330,
;; Boston, MA 02111-1307, USA.
;;
;;; Commentary:
;;
;; Put the following in your .emacs file:
;;
;;  (setq tdiary-diary-list '(("my 1st diary" "http://example.com/tdiary/")
;;                            ("my 2nd diary" "http://example.com/tdiary2/")))
;;  (setq tdiary-text-directory (expand-file-name "~/path-to-saved-diary"))
;;  (setq tdiary-browser-function 'browse-url)
;;  (add-to-list 'auto-mode-alist
;;      '("\\.td$" . tdiary-mode))
;;
;; You can use your own plugin completion, keybindings:
;;
;;  (setq tdiary-plugin-definition
;;    '(
;;      ("STRONG" ("<%=STRONG %Q|" (p "str: ") "| %>"))
;;      ("PRE" ("<%=PRE %Q|" (p "str: ") "| %>"))
;;      ("CITE" ("<%=CITE %Q|" (p "str: ") "| %>"))
;;      ))
;;
;;  (add-hook 'tdiary-mode-hook
;;        '(lambda ()
;;       (local-set-key "\C-i" 'tdiary-complete-plugin)))
;;
;; If you want to save username and password cache to file:
;;
;;  (setq tdiary-passwd-file (expand-file-name "~/.tdiary-pass"))
;;
;; then, M-x tdiary-passwd-cache-save.  !!DANGEROUS!!
;;
;; ToDo:
;; - find plugin definition automatically: needs modification for plugin
;; - Handling authinfo by `auth-source'
;; - create test
;;
;;; Code:
(require 'network-stream)
(require 'tempo)

;; ---------------------------------------------------------------------------
(defgroup tdiary nil
  "Major mode for editing tDiary."
  :prefix "tdiary-"
  :group 'comm)

(defcustom tdiary-diary-list nil
  "List of diary list.
Each element looks like (NAME URL) or (NAME URL INDEX-RB UPDATE-RB)."
  :type '(repeat sexp)
  :group 'tdiary)

(defcustom tdiary-index-rb nil
  "Name of the 'index.rb'."
  :type '(choice (const :tag "Default" nil) string)
  :group 'tdiary)

(defcustom tdiary-update-rb "update.rb"
  "Name of the 'update.rb'."
  :type 'string
  :group 'tdiary)

(defcustom tdiary-coding-system 'utf-8-dos
  "Coding system for tDiary."
  :type 'coding-system
  :group 'tdiary)

(defcustom tdiary-style-mode 'html-mode
  "Major mode to be used for tDiary editing."
  :type 'function
  :group 'tdiary)

(defcustom tdiary-plugin-initial-definition
  '(("my" ("<%=my %Q|" (p "a: ") "|, %Q|" (p "str: ") "| %>"))
    ("fn" ("<%=fn %Q|" (p "footnote: ") "| %>")))
  "Initial definition for tDiary tempo."
  :type '(repeat sexp)
  :group 'tdiary)

(defcustom tdiary-passwd-file nil
  "File path to save password cache."
  :type '(choice (const :tag "None" nil) file)
  :group 'tdiary)

(defcustom tdiary-passwd-file-mode 384 ;; == 0600
  "File mode for `tdiary-passwd-file'."
  :type 'integer
  :group 'tdiary)

(defcustom tdiary-text-directory-mode 448 ;; == 0700
  "Directory mode for `tdiary-text-directory'."
  :type 'integer
  :group 'tdiary)

(defcustom tdiary-csrf-key nil
  "CSRF protection key. check your tdiary.conf"
  :type 'string
  :group 'tdiary)

(defcustom tdiary-hour-offset 0
  "Offset to `current-time'.
`tdiary-today' returns (current-time + tdiary-hour-offset)."
  :type 'integer
  :group 'tdiary)

(defcustom tdiary-text-suffix ".td"
  "Suffix for saved text files."
  :type 'string
  :group 'tdiary)

(defcustom tdiary-text-directory "~/.tdiary-backup/"
  "Directory where diary is stored locally."
  :type 'directory
  :group 'tdiary)

(defcustom tdiary-text-save-p nil
  "Flag for saving text.
If non-nil, tdiary buffer is associated to a real file."
  :type 'boolean
  :group 'tdiary)

(defcustom tdiary-browser-function nil
  "Function to call browser.
If non-nil, `tdiary-update' calls this function."
  :type '(choice (const :tag "None" nil) function)
  :group 'tdiary)

(defcustom tdiary-init-file "~/.tdiary"
  "Init file for tDiary-mode."
  :type 'file
  :group 'tdiary)

(defcustom tdiary-http-proxy-server nil
  "Proxy server for HTTP."
  :type '(choice (const :tag "None" nil) string)
  :group 'tdiary)

(defcustom tdiary-http-proxy-port nil
  "Proxy port for HTTP."
  :type '(choice (const :tag "None" nil) integer)
  :group 'tdiary)

(defcustom tdiary-http-timeout 10
  "Timeout for HTTP in seconds."
  :type 'integer
  :group 'tdiary)

;; ---------------------------------------------------------------------------
(defvar tdiary-diary-name nil
  "Identifier for diary to be updated.")

(defvar tdiary-diary-url nil
  "The tDiary-mode updates this URL.  URL should end with '/'.")

(defvar tdiary-title nil
  "Title of diary.")

(defvar tdiary-date nil
  "Date to be updated.")

(defvar tdiary-edit-mode nil)

(defvar tdiary-plugin-list nil
  "A List of pairs of a plugin name and its completing command.
It is used in `tdiary-complete-plugin'.")

(defvar tdiary-tempo-tags nil
  "Tempo tags for tDiary mode.")

(defvar tdiary-completion-finder "\\(\\(<\\|&\\|<%=\\).*\\)\\="
  "Regexp used to find tags to complete.")

(defvar tdiary-edit-mode-list '(("append") ("replace")))

(defvar tdiary-plugin-definition nil
  "A List of definitions for tDiary tempo.
Each element looks like (NAME ELEMENTS).  NAME is a string that
contains the name of plugin, and ELEMENTS is a list of elements in the
template.  See tempo.info for details.")

(defvar tdiary-complete-plugin-history nil
  "Minibuffer history list for `tdiary-complete-plugin'.")

(defvar tdiary-passwd-cache nil
  "Cache for username and password.")

(defvar tdiary-mode-hook nil
  "Hook run when entering tDiary mode.")

;(defvar tdiary-plugin-dir nil
;  "Path to plugins.  It must be a mounted file system.")
;(defvar tdiary-plugin-definition-regexp "^[ \t]*def[ \t]+\\(.+?\\)[ \t]*\\(?:$\\|;\\|([ \t]*\\(.*?\\)[ \t]*)\\)")

(defvar tdiary--request-url 'unbound
  "Internal variable to pass URL request to tdiary-mode-setup.")

;; ---------------------------------------------------------------------------

(defmacro tdiary-as-binary-process (&rest body)
  "Execute `BODY' as binary.  This macro is imported from apel."
  `(let (selective-display
         (coding-system-for-read  'binary)
         (coding-system-for-write 'binary))
     ,@body))

;; derived from url.el
(defconst tdiary-url-unreserved-chars
  '(
    ?a ?b ?c ?d ?e ?f ?g ?h ?i ?j ?k ?l ?m ?n ?o ?p ?q ?r ?s ?t ?u ?v ?w ?x ?y ?z
       ?A ?B ?C ?D ?E ?F ?G ?H ?I ?J ?K ?L ?M ?N ?O ?P ?Q ?R ?S ?T ?U ?V ?W ?X ?Y ?Z
       ?0 ?1 ?2 ?3 ?4 ?5 ?6 ?7 ?8 ?9
       ?$ ?- ?_ ?. ?! ?~ ?* ?' ?\( ?\) ?,)
  "A list of characters that are _NOT_ reserve in the URL spec.
This is taken from draft-fielding-url-syntax-02.txt - check your local
internet drafts directory for a copy.")

;; derived from url.el
(defun tdiary-url-hexify-string (str coding)
  "Escape characters in a string.
At first, encode STR using CODING, then url-hexify."
  (mapconcat
   (function
    (lambda (char)
      (if (not (memq char tdiary-url-unreserved-chars))
          (if (< char 16)
              (upcase (format "%%0%x" char))
            (upcase (format "%%%x" char)))
        (char-to-string char))))
   (encode-coding-string str coding) ""))

(defun tdiary-http-fetch (url method &optional user pass data)
  "Fetch via HTTP.

URL is a url to be POSTed.
METHOD is 'get or 'post.
USER and PASS must be a valid username and password, if required.
DATA is an alist, each element is in the form of (FIELD . DATA).

If no error, return a buffer which contains output from the web server.
If error, return a cons cell (ERRCODE . DESCRIPTION)."
  (let (connection ssl server port path buf str len)
    (string-match "^http\\(s\\)?://\\([^/:]+\\)\\(:\\([0-9]+\\)\\)?\\(/.*$\\)" url)
    (setq ssl (match-string 1 url)
          server (match-string 2 url)
          port (string-to-number (or (match-string 4 url) (if ssl "443" "80")))
          path (if tdiary-http-proxy-server url (match-string 5 url)))
    (setq str (mapconcat
               #'(lambda (x)
                   (concat (car x) "=" (cdr x)))
               data "&"))
    (setq len (length str))
    (save-excursion
      (setq buf (get-buffer-create (concat "*result from " server "*")))
      (set-buffer buf)
      (erase-buffer)
      (setq connection
            (tdiary-as-binary-process
             (if ssl
                 (open-network-stream (concat "*request to " server "*")
                                      buf
                                      (or tdiary-http-proxy-server server)
                                      (or tdiary-http-proxy-port port)
                                      :type 'tls)
               (open-network-stream (concat "*request to " server "*")
                                    buf
                                    (or tdiary-http-proxy-server server)
                                    (or tdiary-http-proxy-port port)))))
      (process-send-string
       connection
       (concat (if (eq method 'post)
                   (concat "POST " path)
                 (concat "GET " path (if (> len 0)
                                         (concat "?" str))))
               " HTTP/1.0\r\n"
               (concat "Host: " server "\r\n")
               "Connection: close\r\n"
               "Referer: " url "\r\n"
               "Content-type: application/x-www-form-urlencoded\r\n"
               (if (and user pass)
                   (concat "Authorization: Basic "
                           (base64-encode-string
                            (concat user ":" pass))
                           "\r\n"))
               (if (eq method 'post)
                   (concat "Content-length: " (int-to-string len) "\r\n"
                           "\r\n"
                           str))
               "\r\n"))
      (goto-char (point-min))
      (while (not (search-forward "</body>" nil t))
        (unless (accept-process-output connection tdiary-http-timeout)
          (error "HTTP fetch: Connection timeout!"))
        (goto-char (point-min)))
      (goto-char (point-min))
      (save-excursion
        (if (re-search-forward "HTTP/1.[01] \\([0-9][0-9][0-9]\\) \\(.*\\)" nil t)
            (let ((code (match-string 1))
                  (desc (match-string 2)))
              (cond ((equal code "200")
                     buf)
                    (t
                     (cons code desc)))))))))

(defun tdiary-remassoc (key alist)
  "Delete by side effect any elements of ALIST whose car is `equal' to KEY.
The modified ALIST is returned.  If the first member of ALIST has a car
that is `equal' to KEY, there is no way to remove it by side effect;
therefore, write `(setq foo (remassoc key foo))' to be sure of changing
the value of `foo'.  This function imported from apel."
  (while (and (consp alist)
              (or (not (consp (car alist)))
                  (equal (car (car alist)) key)))
    (setq alist (cdr alist)))
  (if (consp alist)
      (let ((prev alist)
            (tail (cdr alist)))
        (while (consp tail)
          (if (and (consp (car alist))
                   (equal (car (car tail)) key))
              ;; `(setcdr CELL NEWCDR)' returns NEWCDR.
              (setq tail (setcdr prev (cdr tail)))
            (setq prev (cdr prev)
                  tail (cdr tail))))))
  alist)

(defun tdiary-tempo-add-tag (def)
  (let* ((plugin (car def))
     (element (cadr def))
     (name (concat "tdiary-" plugin))
     (completer (concat "<%=" plugin))
     (doc (concat "Insert `" plugin "'"))
     (command (tempo-define-template name element completer doc
                     'tdiary-tempo-tags)))
    (add-to-list 'tdiary-plugin-list (list plugin command))))

(defun tdiary-tempo-define (l)
  (mapcar 'tdiary-tempo-add-tag l))

;(defun tdiary-parse-plugin-args (args)
;  (if (null args)
;      nil
;    (mapcar '(lambda (x)
;          (let ((l (split-string x "[ \t]*=[ \t]*")))
;        (if (eq (length l) 1)
;            (car l)
;          l)))
;       (split-string args "[ \t]*,[ \t]*"))))

;(defun tdiary-update-plugin-definition ()
;  (interactive)
;  (let ((files (directory-files tdiary-plugin-dir t ".*\\.rb$" nil t))
;   (buf (generate-new-buffer "*update plugin*")))
;    (save-excursion
;      (save-window-excursion
;   (switch-to-buffer buf)
;   (mapc 'insert-file-contents files)
;   (setq tdiary-plugin-definition nil)
;   (while (re-search-forward tdiary-plugin-definition-regexp nil t)
;     (add-to-list 'tdiary-plugin-definition
;              (list (match-string 1)
;                (tdiary-parse-plugin-args (match-string 2)))))
;   (kill-buffer buf)))))

(defun tdiary-do-complete-plugin (&optional name)
  "Complete function for plugin."
  (let (command)
    (when (null name)
      (setq name
        (completing-read "plugin: " tdiary-plugin-list nil nil nil
                 'tdiary-complete-plugin-history)))
    (setq command (cadr (assoc name tdiary-plugin-list)))
    (when command
      (funcall command))))

;; derived from tempo.el
(defun tdiary-complete-plugin (&optional silent)
  "Look for a HTML tag or plugin and expand it.
If there are no completable text, call `tdiary-do-complete-plugin'."
  (interactive "*")
  (let* ((collection (tempo-build-collection))
     (match-info (tempo-find-match-string tempo-match-finder))
     (match-string (car match-info))
     (match-start (cdr match-info))
     (exact (assoc match-string collection))
     (compl (or (car exact)
            (and match-info (try-completion match-string collection)))))
    (if compl (delete-region match-start (point)))
    (cond ((or (null match-info)
           (null compl))
       (tdiary-do-complete-plugin))
      ((eq compl t) (tempo-insert-template
             (cdr (assoc match-string
                     collection))
             nil))
      (t (if (setq exact (assoc compl collection))
         (tempo-insert-template (cdr exact) nil)
           (insert compl)
           (or silent (ding))
           (if tempo-show-completion-buffer
           (tempo-display-completions match-string
                          collection)))))))

(defun tdiary-today ()
  (let* ((offset-second (* tdiary-hour-offset 60 60))
     (now (current-time))
     (high (nth 0 now))
     (low (+ (nth 1 now) offset-second))
     (micro (nth 2 now)))
    (setq high (+ high (/ low 65536))
      low (% low 65536))
    (when (< low 0)
      (setq high (1- high)
        low (+ low 65536)))
    (list high low micro)))

(defun tdiary-read-username (url name)
  (let ((username (tdiary-passwd-cache-read-username url)))
    (or username
    (read-string (concat "User Name for '" name "': ")))))

(defun tdiary-read-password (url name)
  (let ((password (tdiary-passwd-cache-read-password url)))
    (or password
    (read-passwd (concat "Password for '" name "': ")))))

(defun tdiary-read-date (date)
  (while (not (string-match
           "[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]"
           (setq date (read-string "Date: "
                       (or date
                       (format-time-string "%Y%m%d" (tdiary-today)))))))
    nil)
  date)

(defun tdiary-read-title (date)
  (read-string (concat "Title for " date ": ") tdiary-title))

(defun tdiary-read-mode (mode)
  (let ((default (caar tdiary-edit-mode-list)))
    (completing-read "Editing mode: " tdiary-edit-mode-list
           nil t (or mode default) nil default)))

(defun tdiary-passwd-file-load ()
  "Load password alist."
  (let ((buf (get-buffer-create "*tdiary-passwd-cache*")))
    (when (and tdiary-passwd-file
               (file-readable-p tdiary-passwd-file))
      (with-current-buffer buf
        (insert-file-contents tdiary-passwd-file)
        (setq tdiary-passwd-cache (read buf)))
      (kill-buffer buf))))

(defun tdiary-passwd-file-save ()
  "Save password alist.
Dangerous!!!"
  (interactive)
  (let ((buf (get-buffer-create "*tdiary-passwd-cache*")))
    (with-current-buffer buf
      (erase-buffer)
      (prin1 tdiary-passwd-cache buf)
      (terpri buf)
      (when (and tdiary-passwd-file
                 (file-writable-p tdiary-passwd-file))
        (write-region (point-min) (point-max) tdiary-passwd-file)
        (set-file-modes tdiary-passwd-file tdiary-passwd-file-mode))
      (kill-buffer buf))))

(defun tdiary-passwd-cache-clear (url)
  "Clear cached tdairy password of `URL'."
  (setq tdiary-passwd-cache (tdiary-remassoc url tdiary-passwd-cache)))

(defun tdiary-passwd-cache-save (url user pass)
  "Save cached username:`USER', password:`PASS', `URL' of diary."
  (tdiary-passwd-cache-clear url)
  (add-to-list 'tdiary-passwd-cache
           (cons url (cons user (base64-encode-string pass)))))

(defun tdiary-passwd-cache-read-username (url)
  "Read cached username of the `URL'."
  (cadr (assoc url tdiary-passwd-cache)))

(defun tdiary-passwd-cache-read-password (url)
  "Read cached password of the `URL'."
  (let ((password (cddr (assoc url tdiary-passwd-cache))))
    (and password
     (base64-decode-string password))))

(defun tdiary-post (mode date data)
  "Post `DATA' as diary of `DATE' with `MODE'.  `MODE' is append or replace."
  (let ((url (concat tdiary-diary-url tdiary-update-rb))
    buf title user pass year month day post-data)
    (when (not (equal mode "edit"))
      (setq tdiary-edit-mode (setq mode (tdiary-read-mode mode)))
      (setq tdiary-date (setq date (tdiary-read-date date)))
      (setq tdiary-title (setq title (tdiary-read-title date))))
    (setq user (tdiary-read-username url tdiary-diary-name))
    (setq pass (tdiary-read-password url tdiary-diary-name))
    (string-match "\\([0-9][0-9][0-9][0-9]\\)\\([0-9][0-9]\\)\\([0-9][0-9]\\)"
          date)
    (setq year (match-string 1 date)
      month (match-string 2 date)
      day (match-string 3 date))
    (push (cons "old" date) post-data)
    (push (cons "year" year) post-data)
    (push (cons "month" month) post-data)
    (push (cons "day" day) post-data)
    (if tdiary-csrf-key (push (cons "csrf_protection_key" tdiary-csrf-key) post-data))
    (or (equal mode "edit")
        (push (cons "title"
                    (tdiary-url-hexify-string
                     title
                     tdiary-coding-system))
              post-data))
    (push (cons mode mode) post-data)
    (and data
         (push (cons "body"
                     (tdiary-url-hexify-string
                      data
                      tdiary-coding-system))
               post-data))
    (setq buf (tdiary-http-fetch url 'post user pass post-data))
    (if (bufferp buf)
        (progn
          (tdiary-passwd-cache-save url user pass)
          (set-buffer buf)
          (decode-coding-region (point-min) (point-max) tdiary-coding-system)
          (goto-char (point-min))
          buf)
      (tdiary-passwd-cache-clear url)
      (error "The tDiary POST: %s - %s" (car buf) (cdr buf)))))

(defun tdiary-post-text ()
  "Post tDiary data"
  (let* ((site-name (or tdiary-diary-name "default"))
         (base-dir  (or tdiary-text-directory (expand-file-name "~/.tdiary-backup/")))
         (dirname   (expand-file-name site-name base-dir))
         (filename  (expand-file-name (concat tdiary-date tdiary-text-suffix) dirname)))
    (unless (file-directory-p dirname)
      (make-directory dirname t)
      (set-file-modes dirname tdiary-text-directory-mode))

    ;; If buffer-file-name is tdiary-text-directory/tdiary-diary-name/yyyymmdd.td
    ;; do nothing.
    (let ((current-file (and buffer-file-name (expand-file-name buffer-file-name))))
      (unless (equal filename current-file)
        (cond
         ((equal tdiary-edit-mode "replace")
          (write-region (point-min) (point-max) filename))
         ((equal tdiary-edit-mode "append")
          (write-region (point-min) (point-max) filename t)))))))

(defun tdiary-update ()
  "Update diary."
  (interactive)
  (unless (and (eq (char-before (point-max)) ?\n)
           (eq (char-before (1- (point-max))) ?\n))
    (save-excursion
      (goto-char (point-max))
      (insert "\n")))
  (tdiary-post tdiary-edit-mode tdiary-date
           (buffer-substring (point-min) (point-max)))
  (when tdiary-text-save-p
    (tdiary-post-text))
  (if buffer-file-name
      (save-buffer)
    (set-buffer-modified-p nil))
  (message "SUCCESS")
  (and (functionp tdiary-browser-function)
       (funcall tdiary-browser-function
        (concat tdiary-diary-url tdiary-index-rb
            "?date=" tdiary-date))))

(defun tdiary-replace-entity-refs (&optional str)
  "Replace entity references.

If STR is a string, replace entity references within the string.
Otherwise replace all entity references within current buffer."
  (let ((entities '(("&amp;"  . "&")
                    ("&lt;"   . "<")
                    ("&gt;"   . ">")
                    ("&quot;" . "\"")
                    ("&#39;"  . "'")
                    ("&#x27;" . "'")
                    ("&apos;" . "'"))))
    (if (stringp str)
        (progn
          (dolist (ent entities)
            (setq str (replace-regexp-in-string (regexp-quote (car ent))
                                                (cdr ent)
                                                str t t)))
          str)
      (save-excursion
        (dolist (ent entities)
          (goto-char (point-min))
          (while (search-forward (car ent) nil t)
            (replace-match (cdr ent) t t)))))))

;; (defun tdiary-read-mode (mode)
;;   (let ((default (caar tdiary-edit-mode-list)))
;;     (completing-read "Editing mode: " tdiary-edit-mode-list
;;           nil t (or mode default) nil default)))

(defun tdiary-obsolete-check ()
  "Setting tdiary-diary-url in tdiary-init-file is obsolete."
  (when tdiary-diary-url
    (message "tdiary-diary-url is OBSOLETE.  Use tdiary-diary-list instead of tdiary-diary-url.")
    (sit-for 5)))

;;;###autoload
(defun tdiary-setup-diary-url (url)
  "Setting tdiary url:`URL'.
The tdiary-diary-url in tdiary-init-file is obsolete."
  (tdiary-obsolete-check)
  (unless tdiary-diary-url
    (let* ((selected (car tdiary-diary-list))
           (default (car selected)))
      (when url
        (setq selected (assoc (completing-read "Select SITE: " tdiary-diary-list
                                               nil t default nil default)
                              tdiary-diary-list)))
      (setq tdiary-diary-name (nth 0 selected)
            tdiary-diary-url (nth 1 selected))
      (and (eq (length selected) 4)
           (setq tdiary-index-rb (nth 2 selected)
                 tdiary-update-rb (nth 3 selected))))))

(defun tdiary--new-or-replace (replacep url)
  (let ((edit-buf (generate-new-buffer "*tdiary tmp*")))
    (switch-to-buffer edit-buf)
    (let ((tdiary--request-url url))
      (tdiary-mode))
    (setq tdiary-edit-mode "append")
    (let (start body title csrf-key http-buf)
      (setq http-buf (tdiary-post "edit" tdiary-date nil))
      (when (bufferp http-buf)
        (with-current-buffer http-buf
          (let ((case-fold-search t))
            (goto-char (point-min))
            (when (re-search-forward "name=[\"']csrf_protection_key[\"'][^>]*value=[\"']\\([^\"']*\\)[\"']" nil t)
              (setq csrf-key (match-string 1)))
            (goto-char (point-min))
            (when (re-search-forward "name=[\"']title[\"'][^>]*value=[\"']\\([^\"']*\\)[\"']" nil t)
              (setq title (match-string 1)))
            (goto-char (point-min))
            (if (re-search-forward "<textarea[^>]*>" nil t)
                (progn
                  (setq start (match-end 0))
                  (if (re-search-forward "</textarea>" nil t)
                      (setq body (buffer-substring start (match-beginning 0)))
                    (setq body "")))
              (setq body ""))))
        (with-current-buffer edit-buf
          (setq tdiary-csrf-key (and csrf-key (tdiary-replace-entity-refs csrf-key)))
          (when replacep
            (if (and (stringp body) (> (length body) 0))
                (insert body)
              ;; (insert "【デバッグ出力：抽出失敗】\n")
              )
            (setq tdiary-edit-mode "replace")
            (when title
              (setq tdiary-title (tdiary-replace-entity-refs title)))
            (goto-char (point-min))
            (tdiary-replace-entity-refs)
            (if (and tdiary-text-save-p buffer-file-name)
                (save-buffer)
              (set-buffer-modified-p nil))))))))

;;;###autoload
(defun tdiary-new (&optional url)
  "Create New diary of URL:`URL'."
  (interactive "P")
  (tdiary--new-or-replace nil url))

;;;###autoload
(defun tdiary-replace (&optional url)
  "Replace New diary of URL:`URL'."
  (interactive "P")
  (tdiary--new-or-replace t url))

(defvar tdiary-mode-map (make-sparse-keymap)
  "Set up keymap for tdiary-mode.
If you want to set up your own key bindings, use `tdiary-mode-hook'.")

(define-key tdiary-mode-map [(control return)] 'tdiary-complete-plugin)
(define-key tdiary-mode-map "\C-c\C-c" 'tdiary-update)

(push (cons 'tdiary-date tdiary-mode-map) minor-mode-map-alist)
(if (boundp 'minor-mode-list) (push 'tdiary-mode minor-mode-list))
(push '(tdiary-date " tDiary") minor-mode-alist)

(defun tdiary-load-init-file ()
  "Load init file."
  (let ((init-file (expand-file-name tdiary-init-file)))
    (when (file-readable-p init-file)
      (load init-file t t))))

(defun tdiary-make-temp-file-name ()
  "Get the local backup file name for the diary (bypassing /tmp/)."
  (let* ((site-name (or tdiary-diary-name "default"))
         (base-dir  (or tdiary-text-directory (expand-file-name "~/.tdiary-backup/")))
         (dirname   (expand-file-name site-name base-dir)))
    (unless (file-directory-p dirname)
      (make-directory dirname t)
      (set-file-modes dirname tdiary-text-directory-mode))
    (expand-file-name (concat tdiary-date tdiary-text-suffix) dirname)))

(defun tdiary-html-mode-init ()
  "Initialize tDiary for default style."
  (tdiary-tempo-define (append tdiary-plugin-initial-definition
                   tdiary-plugin-definition))
  (tempo-use-tag-list 'tdiary-tempo-tags tdiary-completion-finder))

(defun tdiary-rd-mode-init ()
  "Initialize tDiary for RD style."
  )

(defun tdiary-mode ()
  "The tDiary editing mode.
The value of `tdiary-style-mode' will be used as actual major mode.

\\{tdiary-mode-map}"
  (interactive)
  (funcall tdiary-style-mode)
  (and (featurep 'font-lock)
       (font-lock-set-defaults))
  (tdiary-mode-setup))

(defun tdiary-mode-setup ()
  "Set tDiary mode up."
  (interactive)
  (make-local-variable 'require-final-newline)
  (make-local-variable 'tdiary-date)
  (make-local-variable 'tdiary-title)
  (make-local-variable 'tdiary-edit-mode)
  (make-local-variable 'tdiary-diary-url)
  (make-local-variable 'tdiary-index-rb)
  (make-local-variable 'tdiary-update-rb)
  (make-local-variable 'tdiary-csrf-key)
  (setq require-final-newline t
        indent-tabs-mode nil
        tdiary-edit-mode "replace"
        tdiary-date (format-time-string "%Y%m%d" (tdiary-today)))
  (tdiary-load-init-file)
  (tdiary-setup-diary-url (if (eq tdiary--request-url 'unboundq)
                              select-url
                            t))
  (set-buffer-file-coding-system tdiary-coding-system)
  (or tdiary-passwd-cache
      (tdiary-passwd-file-load))
  (if buffer-file-name
      (let ((buf-name (file-name-nondirectory buffer-file-name)))
        (when (string-match
               "\\([0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]\\)"
               buf-name)
          (setq tdiary-date (match-string 1 buf-name))))
    (setq tdiary-date (tdiary-read-date nil))
    (if tdiary-text-save-p
        (unless buffer-file-name
          (let ((change-major-mode-with-file-name nil))
            (set-visited-file-name (tdiary-make-temp-file-name))))
      (unless (string= (buffer-name) tdiary-date)
        (rename-buffer tdiary-date t))))
  (let ((init (intern (concat "tdiary-" (symbol-name tdiary-style-mode) "-init"))))
    (if (fboundp init) (funcall init)))
  (run-hooks 'tdiary-mode-hook))

(defun tdiary-mode-toggle (&optional arg)
  "Toggle tdiary-mode via `ARG'."
  (interactive "P")
  (let ((in-tdiary (and (boundp 'tdiary-date) tdiary-date)))
    (cond ((not arg)
       (setq arg (not in-tdiary)))
      ((or (eq arg '-) (and (numberp arg) (< arg 0)))
       (setq arg nil)))
    (cond (arg
       (tdiary-mode-setup))
      (in-tdiary
       (setq tdiary-date nil)))))

(provide 'tdiary-mode)
;;; tdiary-mode.el ends here
