(defun my/flyspell-auto-correct-word ()
  "If the last entered character is SPC, then run flyspell-auto-correct-word on the last word "
  (interactive)
  (let (previousChar nextChar)
    ;; get the char before point.  If you have just pressed the space bar, then the char before point is SPC.
    ;; if you have just pressed "h", then the char before point is "h".
    (setq previousChar
          (substring (buffer-substring (- (point) 1) (point)) 0))
    (setq nextChar
          (substring (buffer-substring (point) (+ 1 (point))) 0))
    (when (string= previousChar " ")
      (flyspell-auto-correct-word)
      (if (string= nextChar "\n")
          (insert " ")
        (forward-char)))))

(defun add-my-flyspell-auto-correct-word-hook ()
  "This function adds my/flyspell-auto-correct-word function to be run after post-self-insert-hook."
  (interactive)
  (add-hook 'post-self-insert-hook 'my/flyspell-auto-correct-word))

(defun remove-my-flyspell-auto-correct-word-hook ()
  "This function adds my/flyspell-auto-correct-word function to be run after post-self-insert-hook."
  (interactive)
  (remove-hook 'post-self-insert-hook 'my/flyspell-auto-correct-word))

(provide 'init-autocorrect)
