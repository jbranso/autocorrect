(ert-deftest autocorrect-testing-my-regexp ()
  (should (string-match autocorrect-regexp "the" ))
  (should (string-match autocorrect-regexp "the." ))
  (should (string-match autocorrect-regexp "the?" ))
  (should (string-match autocorrect-regexp "the," ))
  (should (string-match autocorrect-regexp "the;" ))
  (should (string-match autocorrect-regexp "the!" ))
  (should (string-match autocorrect-regexp "the..." ))
  (should (string-match autocorrect-regexp "the\"" ))
  (should (string-match autocorrect-regexp "the" ))
  (should-not (string-match autocorrect-regexp "the21" ))
  (should-not (string-match autocorrect-regexp "21the" ))
  (should-not (string-match autocorrect-regexp "t.he" ))
  (should-not (string-match autocorrect-regexp "t?he" ))
  (should-not (string-match autocorrect-regexp "t?h@e" ))
  (should-not (string-match autocorrect-regexp "th$e" ))
  (should-not (string-match autocorrect-regexp "theh#e" ))
  (should-not (string-match autocorrect-regexp "theh#e" ))
  (should-not (string-match autocorrect-regexp "th%ehe" ))
  (should-not (string-match autocorrect-regexp "t^hehe" ))
  (should-not (string-match autocorrect-regexp "the&he" ))
  (should-not (string-match autocorrect-regexp "t*hehe" )))

(defun reg-test/go-to-before (reg-test/buffer)
  "go to the before line."
  (interactive)
  (find-file-noselect (concat "~/programming/emacs/autocorrect/tests/" reg-test/buffer))
  (with-current-buffer reg-test/buffer
    (beginning-of-buffer)
    (search-forward "* before")
    (next-line)
    (beginning-of-line)
    (forward-char 3)
    (let (reg-test/point)
      (setq reg-test/point
            (point))
      reg-test/point)))

(defun reg-test/go-to-after (reg-test/buffer)
  "go to the before line."
  (interactive)
  (find-file-noselect (concat "~/programming/emacs/autocorrect/tests/" reg-test/buffer))
  (with-current-buffer reg-test/buffer
    (beginning-of-buffer)
    (search-forward "* after")
    (next-line)
    (beginning-of-line)
    (forward-char 3)
    (let (reg-test/point)
      (setq reg-test/point (point))
      reg-test/point)))

(defun reg-test/get-before-line-number (reg-test/buffer)
  "This returns the line number at the before heading."
  (find-file-noselect (concat "~/programming/emacs/autocorrect/tests/" reg-test/buffer))
  (let (reg-test/line-number)
    (with-current-buffer reg-test/buffer
      (goto-char (reg-test/go-to-before reg-test/buffer))
      (setq reg-test/line-number
            (line-number-at-pos)))
    reg-test/line-number)
  )

(defun reg-test/get-after-line-number (reg-test/buffer)
  "This returns the line number at the before heading."
  (find-file-noselect (concat "~/programming/emacs/autocorrect/tests/" reg-test/buffer))
  (let (reg-test/line-number)
    (with-current-buffer reg-test/buffer
      (goto-char (reg-test/go-to-after reg-test/buffer))
      (setq reg-test/line-number
            (line-number-at-pos)))
    reg-test/line-number))

(require 'ert)
(defun reg-test/get-before (reg-test/buffer)
  "This returns the before text."
  (interactive)
  ;;(reg-test/go-to-before reg-test/buffer)
  (find-file-noselect (concat "~/programming/emacs/autocorrect/tests/" reg-test/buffer))
  (with-current-buffer reg-test/buffer
    (goto-char (reg-test/go-to-before reg-test/buffer))
    (buffer-substring-no-properties (point) (progn
                                (search-forward-regexp "$")
                                (point)))))

(defun reg-test/get-after (reg-test/buffer)
  "This returns the before text."
  (interactive)
  (find-file-noselect (concat "~/programming/emacs/autocorrect/tests/" reg-test/buffer))
  (with-current-buffer reg-test/buffer
    (goto-char (reg-test/go-to-after reg-test/buffer))
    (buffer-substring-no-properties (point) (progn
                                (search-forward-regexp "$")
                                (point)))))

(defun reg-test/correct-all-words-on-current-line (line reg-test/buffer)
  "This function will move to each word on the line, and press the space bar, which will call my/flyspell-auto-correct-word."
  (interactive)
  (forward-word)
  ;; I am now at the end of a word
  (when (equal line (line-number-at-pos))
    (insert " ")
    (autocorrect-flyspell-autocorrect-word)
    (reg-test/correct-all-words-on-current-line line reg-test/buffer)))

(defun reg-test/autocorrect-words-are-correct (reg-test/buffer)
  "This function runs the test specifies in ./tests/words-are-correct.org"
  (interactive)
  (find-file-noselect (concat "~/programming/emacs/autocorrect/tests/" reg-test/buffer))
  (with-current-buffer reg-test/buffer
    (goto-char (reg-test/go-to-before reg-test/buffer))
    (reg-test/correct-all-words-on-current-line
     (reg-test/get-before-line-number reg-test/buffer)
     reg-test/buffer)))

(ert-deftest autocorrect-words-are-correct ()
  (let (reg-test/buffer)
    (setq reg-test/buffer "words-are-correct.org")
    (reg-test/autocorrect-words-are-correct reg-test/buffer)
    (should (let (stringEqual)
              (setq stringEqual
                    (string= (reg-test/get-before reg-test/buffer) (reg-test/get-after reg-test/buffer)))
              ;;(kill-buffer reg-test/buffer)
              stringEqual))))
