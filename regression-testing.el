(defun reg-test/go-to-before (reg-test/buffer)
  "go to the before line."
  (interactive)
  (find-file (concat "~/programming/emacs/autocorrect/tests/" reg-test/buffer))
  (beginning-of-buffer)
  (search-forward "* before")
  (next-line)
  (beginning-of-line)
  (forward-char 3))

(defun reg-test/go-to-after (reg-test/buffer)
  "go to the before line."
  (interactive)
  (find-file (concat "~/programming/emacs/autocorrect/tests/" reg-test/buffer))
  (beginning-of-buffer)
  (search-forward "* after")
  (next-line)
  (beginning-of-line)
  (forward-char 3)
  )

(defun reg-test/get-before-line-number (reg-test/buffer)
  "This returns the line number at the before heading."
  (reg-test/go-to-before reg-test/buffer)
  (line-number-at-pos))

(defun reg-test/get-after-line-number (reg-test/buffer)
  "This returns the line number at the before heading."
  (reg-test/go-to-after reg-test/buffer)
  (line-number-at-pos))

(require 'ert)
(defun reg-test/get-before (reg-test/buffer)
  "This returns the before text."
  (interactive)
  (reg-test/go-to-before reg-test/buffer)
  (let (string-before)
    (setq string-before (buffer-substring (point) (progn
                                                    (search-forward-regexp "$")
                                                    (point))))
    string-before))

(defun reg-test/get-after (reg-test/buffer)
  "This returns the before text."
  (interactive)
  (reg-test/go-to-after reg-test/buffer)
  (let (string-after)
    (setq string-after
          (buffer-substring (point) (progn
                                      (search-forward-regexp "$")
                                      (point))))
    string-after))

(defun reg-test/correct-all-words-on-current-line (line reg-test/buffer)
  "This function will move to each word on the line, and press the space bar, which will call my/flyspell-auto-correct-word."
  (interactive)
  (forward-word)
  ;; I am now at the end of a word
  (if (equal line (line-number-at-pos))
      (progn
        (insert " ")
        (my/flyspell-auto-correct-word)
        (reg-test/correct-all-words-on-current-line line reg-test/buffer))
    t))

(defun reg-test/autocorrect-words-are-correct (reg-test/buffer)
  "This function runs the test specifies in ./tests/words-are-correct.org"
  (interactive)
  (reg-test/correct-all-words-on-current-line
   (reg-test/get-before-line-number reg-test/buffer)
   reg-test/buffer))

(ert-deftest autocorrect-words-are-correct ()
  (let (reg-test/buffer)
    (setq reg-test/buffer "words-are-correct.org")
    (reg-test/autocorrect-words-are-correct reg-test/buffer)
    (should (let (stringEqual)
              (setq stringEqual
                    (string= (reg-test/get-before reg-test/buffer) (reg-test/get-after reg-test/buffer)))
              (kill-buffer reg-test/buffer)
              stringEqual)))
  )


(defun thisShouldReturnT ()
  ""
  (interactive)
  (let (reg-test/buffer)
    (setq reg-test/buffer "words-are-correct.org")
    (reg-test/autocorrect-words-are-correct reg-test/buffer)
    (let (stringEqual)
      (setq stringEqual
            (string= (reg-test/get-before reg-test/buffer) (reg-test/get-after reg-test/buffer)))
      (kill-buffer reg-test/buffer)
      stringEqual))) 

;;      (thisShouldReturnT)


(reg-test/autocorrect-words-are-correct "words-are-correct.org")
(setq stringEqual
      (string= (reg-test/get-before "words-are-correct.org") (reg-test/get-after "words-are-correct.org")))
