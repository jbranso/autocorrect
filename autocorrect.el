(defvar autocorrect-regexp "^[a-zA-Z]+[;.,?!)\"]\\{0,3\\}$"
  "autocorrect-regexp is the regexp that makes sure the word is a word that we want to try to correct.
For example, my package should not try to correct a variable name.  So any word with any special
symbols in the middle of it or numbers, should not be corrected.")

(defun autocorrect-is-word-correctable (string)
  (if (string= major-mode "org-mode")
      (and
       (string-match autocorrect-regexp string)
       (not (string= "src-block"
                     (car (org-element-at-point)))))
    (string-match autocorrect-regexp string)))

(defun reg-test/previous-word ()
  "Returns the previous word in the buffer."
  (interactive)
  (let (reg-test/previous-word current-point)
    (setq current-point (point))
    (setq reg-test/previous-word (progn
                                   (backward-word)
                                   (word-at-point)))
    (goto-char current-point)
    reg-test/previous-word))

(defun autocorrect-flyspell-autocorrect-word ()
  "If the last entered character is SPC, then run flyspell-auto-correct-word on the last word "
  (interactive)
  (let (previous-word previous-char next-char current-point)
    (setq current-point (point))
    (setq previous-word (reg-test/previous-word))
    ;; get the char before point.  If you have just pressed the space bar, then the char before point is SPC.
    ;; if you have just pressed "h", then the char before point is "h".
    (setq previous-char
          (substring (buffer-substring (- (point) 1) (point)) 0))
    (setq next-char
          (substring (buffer-substring (point) (+ 1 (point))) 0))
    (when (and (string= previous-char " ")
               ;; the string should just be alphanumeric characters, or it might have punctuation at the end.  Like "Hello?"
               ;; (additional details)
               ;; "I am a sentence," said me.
               ;; "I don't care what you think," said Sally, "but if you would like, I can punch you in the face."
               (autocorrect-is-word-correctable previous-word))
      (progn
        (flyspell-auto-correct-word)))
    (goto-char current-point)))

(defun autocorrect-mode-is-a-prog-mode ())
(let (return-value)
  (setq return-value
        (string= "Parent mode: `prog-mode"
                 (substring (describe-function major-mode)
                            (search "Parent mode:"
                                    (describe-function major-mode))
                            119)))
  (delete-window
   (get-buffer-window "*Help*"))
  return-value)

(defun autocorrect-mode-is-a-text-mode ()
  (let (return-value)
    (setq return-value
          (string= "Parent mode: `text-mode"
                   (substring (describe-function major-mode)
                              (search "Parent mode:"
                                      (describe-function major-mode))
                              119)))
    (delete-window
     (get-buffer-window "*Help*"))
    return-value))

(defun autocorrect-add-autocorrect-hook ()
  "This function adds autocorrect-flyspell-autocorrect-word function to be run after post-self-insert-hook."
  (interactive)
  (add-hook 'post-self-insert-hook 'autocorrect-flyspell-autocorrect-word))

(defun autocorrect-remove-autocorrect-hook ()
  "This function adds autocorrect-flyspell-autocorrect-word function to be run after post-self-insert-hook."
  (interactive)
  (remove-hook 'post-self-insert-hook 'autocorrect-flyspell-autocorrect-word))

(add-hook 'minibuffer-inactive-mode-hook 'autocorrect-remove-autocorrect-hook)

(add-hook 'text-mode-hook #'autocorrect-add-autocorrect-hook)
(add-hook 'programming-mode-hook #'autocorrect-remove-autocorrect-hook)

(defun autocorrect-maybe-turn-on-autocorrect ()
  "This function checks to see if the current major-mode is text mode or org-mode.  If either is true, then it turns on
  autocorrecting.  If neither is true, then it turns off autocorrecting."
  (interactive)
  (cond
   ((string= major-mode "org-mode") (autocorrect-add-autocorrect-hook))
   ((autocorrect-mode-is-a-text-mode) (autocorrect-add-autocorrect-hook))
   ((autocorrect-remove-autocorrect-hook))))

(cond
 ((string= "hello" "heo") (print "hello"))
 ((string= "hello" "hello") (print "yes")))
;;(add-hook 'after-change-major-mode-hook #'autocorrect-maybe-turn-on-autocorrect)
;;(remove-hook 'after-change-major-mode-hook #'autocorrect-maybe-turn-on-autocorrect)

(provide 'init-autocorrect)
