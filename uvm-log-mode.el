;; test of standard uvm report log mode

(defcustom stupid-uvm-log-mode-hook nil
  "Hook run after init of stupid uvm log mode"
  :group 'stupid-uvm-log-mode
  :type 'hook)

;; Defien mode map
(defvar stupid-uvm-log-mode-map nil "the key map for stupid UVM log mode")

;; needs to bae a list as the simulator might insert non UVM lines
(setq urlm-fatal-key-list '("UVM_FATAL" "** Fatal:" "Fatal:"))
(setq urlm-error-key-list '("UVM_ERROR" "** Error:" "Error:" "Error-"))
(setq urlm-critical-w-key-list '("UVM_CRITICAL_WARNING"))
(setq urlm-warning-key-list '("UVM_WARNING" "** Warning:" "Warning:"))
(setq urlm-info-key-list '("UVM_INFO" "** Info:" "Info:"))
(setq urlm-wrap-up-list '("--- UVM Report Summary ---" "$finish"))

(setq urlm-all-keys (append urlm-fatal-key-list urlm-error-key-list urlm-critical-w-key-list urlm-warning-key-list urlm-info-key-list urlm-wrap-up-list))
(setq urlm-keys-re (regexp-opt urlm-all-keys t))
;; make regexp
(setq urlm-fatal-regexp (regexp-opt urlm-fatal-key-list 'word))
(setq urlm-error-regexp (regexp-opt urlm-error-key-list 'word))
(setq urlm-critical-w-regexp (regexp-opt urlm-critical-w-key-list 'word))
(setq urlm-warning-regexp (regexp-opt urlm-warning-key-list 'word))
(setq urlm-info-regexp (regexp-opt urlm-info-key-list 'word))

;; define colors
(defface urlm-fatal-face '((t :foreground "red")) "Fatal keyword look" :group 'stupud-uvm-log-mode)
(defface urlm-error-face '((t :foreground "orange red")) "Error keyword look" :group 'stupud-uvm-log-mode)
(defface urlm-critical-warning-face '((t :foreground "gold")) "Critical Warning keyword look" :group 'stupud-uvm-log-mode)
(defface urlm-warning-face '((t :foreground "yellow")) "Warning keyword look" :group 'stupud-uvm-log-mode)
(defface urlm-info-face '((t :foreground "green")) "Info keyword look" :group 'stupud-uvm-log-mode)

;(face-spec-set 'urlm-fatal-face            '((t :foreground "red"))          'face-defface-spec)
;(face-spec-set 'urlm-error-face            '((t :foreground "light red"))    'face-defface-spec)
;(face-spec-set 'urlm-critical-warning-face '((t :foreground "yellow"))       'face-defface-spec)
;(face-spec-set 'urlm-warning-face          '((t :foreground "light yellow")) 'face-defface-spec)
;(face-spec-set 'urlm-info-face             '((t :foreground "green"))        'face-defface-spec)

;; combine regexp and face
(setq urlm-color-scheame
      `(
        (,urlm-fatal-regexp . 'urlm-fatal-face)
        (,urlm-error-regexp . 'urlm-error-face)
        (,urlm-critical-w-regexp . 'urlm-critical-warning-face)
        (,urlm-warning-regexp . 'urlm-warning-face)
        (,urlm-info-regexp . 'urlm-info-face)
        ))

(defun urlm-get-next-entry ()
  (if (re-search-forward urlm-keys-re)
      (goto-char (match-beginning 1))
    nil))

(defun sulm-set-hide-verbosity ()
  (interactive)
  (setq buffer-invisibility-spec nil)
  ;(add-to-invisibility-spec 'stupid-uvm-log-cw)
  ;(add-to-invisibility-spec 'stupid-uvm-log-w)
  ;(add-to-invisibility-spec 'stupid-uvm-log-i)
  (save-excursion
    (goto-char (point-min))
    (let (begin invi (hide nil))
      (while (not (eobp))
        ;(message "%d" (point))
        (if (re-search-forward urlm-keys-re nil t)
            (progn
              (if hide
                  (progn
                    (put-text-property begin (match-beginning 1) 'invisible invi)
                    (put-text-property begin (match-beginning 1) 'field begin)))
              (setq begin (match-beginning 1))
              (cond
               ((member (match-string 1) urlm-critical-w-key-list)
                (setq invi 'stupid-uvm-log-cw)
                (setq hide t))
               ((member (match-string 1) urlm-warning-key-list)
                (setq invi 'stupid-uvm-log-w)
                (setq hide t))
               ((member (match-string 1) urlm-info-key-list)
                (setq invi 'stupid-uvm-log-i)
                (setq hide t))
               ((member (match-string 1) urlm-wrap-up-list)
                (goto-char (point-max))
                (setq hide nil))
               (t (setq hide nil))))
          (goto-char (point-max))))
      (if hide
          (progn
            (put-text-property begin (point) 'invisible invi)
            (put-text-property begin (point) 'field begin)))))) ; how to find the end of the entrys and the begining of the rapup??

(defun sulm-view-critical-warning ()
  (interactive)
  (remove-from-invisibility-spec 'stupid-uvm-log-cw))

(defun sulm-view-warning ()
  (interactive)
  (remove-from-invisibility-spec 'stupid-uvm-log-w))

(defun sulm-view-info ()
  (interactive)
  (remove-from-invisibility-spec 'stupid-uvm-log-i))

(defun sulm-toggle-view ()
  (interactive)
  (if (invisible-p 'stupid-uvm-log-cw)
      (progn
        (add-to-invisibility-spec 'stupid-uvm-log-w)
        (add-to-invisibility-spec 'stupid-uvm-log-i)
        (remove-from-invisibility-spec 'stupid-uvm-log-cw))
    (if (invisible-p 'stupid-uvm-log-w)
        (progn
          (add-to-invisibility-spec 'stupid-uvm-log-i)
          (remove-from-invisibility-spec 'stupid-uvm-log-w))
      (if (invisible-p 'stupid-uvm-log-i)
          (remove-from-invisibility-spec 'stupid-uvm-log-i)
        (progn
          (add-to-invisibility-spec 'stupid-uvm-log-cw)
          (add-to-invisibility-spec 'stupid-uvm-log-w)
          (add-to-invisibility-spec 'stupid-uvm-log-i))))))

(defun sulm-before-change (start end)
  (message (buffer-substring-no-properties start end)))

(defun sulm-occur (regexp)
  (interactive "sregexp:")
  (let ((obuf (concat "*soccur_" regexp "*"))
        (last-field "aaaa"))
    (when (get-buffer obuf)
      (kill-buffer obuf))
    (with-current-buffer (current-buffer)
      (save-excursion
        (goto-char (point-min))
        (while (re-search-forward regexp nil t)
          (unless (equal (get-text-property (point) 'field) last-field)
            (setq last-field (get-text-property (point) 'field))
            (let ((str (field-string-no-properties)))
              (get-buffer-create obuf)
              (if str
                  (progn
                    (with-current-buffer obuf
                      (insert str)
                      (or (zerop (current-column))
                          (insert "\n"))))))))))
    (pop-to-buffer obuf)
    (with-current-buffer obuf
      (uvm-log-mode))))

(defun sulm-isearch-hook ()
  (define-key isearch-mode-map (kbd "C-o")
    (lambda () (interactive)
      (let ((case-fold-search isearch-case-fold-search))
        (sulm-occur isearch-string)))))

(defun sulm-build-mode-map ()
  (setq stupid-uvm-log-mode-map (make-sparse-keymap))
  (define-key stupid-uvm-log-mode-map (kbd "t") 'sulm-toggle-view))

(define-derived-mode uvm-log-mode
  fundamental-mode "uvm-log"
  "Major mode for viewing UVM logs"
  (setq show-trailing-whitespace nil)
  (setq font-lock-defaults '(urlm-color-scheame))
  (buffer-disable-undo)
  (sulm-build-mode-map)
  (use-local-map stupid-uvm-log-mode-map)
  (sulm-set-hide-verbosity)
  ;(add-hook 'before-change-functions 'sulm-before-change nil t)
  (add-hook 'isearch-mode-hook 'sulm-isearch-hook nil t)
  (read-only-mode)
  (hl-line-mode)
  (view-mode))

(provide 'uvm-log-mode)
