(defvar autocorrect-regexp "^[a-zA-Z]+[;.,?!)\"]\\{0,3\\}$"
  "autocorrect-regexp is the regexp that makes sure the word is a word that we want to try to correct.
For example, my package should not try to correct a variable name.  So any word with any special
symbols in the middle of it or numbers, should not be corrected.")

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

(defun my/flyspell-auto-correct-word ()
  "If the last entered character is SPC, then run flyspell-auto-correct-word on the last word "
  (interactive)
  (let (previousWord previousChar nextChar current-point)
    (setq current-point (point))
    (setq previousWord (reg-test/previous-word))
    ;; get the char before point.  If you have just pressed the space bar, then the char before point is SPC.
    ;; if you have just pressed "h", then the char before point is "h".
    (setq previousChar
          (substring (buffer-substring (- (point) 1) (point)) 0))
    (setq nextChar
          (substring (buffer-substring (point) (+ 1 (point))) 0))
    (when (and (string= previousChar " ")
               ;; the string should just be alphanumeric characters, or it might have punctuation at the end.  Like "Hello?"
               ;; (additional details)
               ;; "I am a sentence," said me.
               ;; "I don't care what you think," said Sally, "but if you would like, I can punch you in the face."
               (string-match autocorrect-regexp previousWord ))
      (progn
        (flyspell-auto-correct-word)))
    (goto-char current-point)))

(defun add-autocorrect-hook ()
  "This function adds my/flyspell-auto-correct-word function to be run after post-self-insert-hook."
  (interactive)
  (add-hook 'post-self-insert-hook 'my/flyspell-auto-correct-word))

(defun remove-autocorrect-hook ()
  "This function adds my/flyspell-auto-correct-word function to be run after post-self-insert-hook."
  (interactive)
  (remove-hook 'post-self-insert-hook 'my/flyspell-auto-correct-word))

(add-hook 'minibuffer-inactive-mode-hook 'remove-autocorrect-hook)

(add-hook 'text-mode-hook #'add-autocorrect-hook)
(add-hook 'programming-mode-hook #'remove-autocorrect-hook)

(provide 'init-autocorrect)

(defun autocorrect-mode-is-a-prog-mode ())


(string= "Parent mode: `prog-mode"
         (substring (describe-function 'emacs-lisp-mode)
                    (search "Parent mode:"
                            (describe-function 'emacs-lisp-mode))
                    119))
(delete-window
 (get-buffer-window "*Help*"))
