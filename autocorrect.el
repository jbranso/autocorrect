;;; autocorrect.el --- automatically attempt to correct misspelled words as you type them.

;;; Copyright (C) 2016
;;
;;
;; Author: Joshua Branson
;; Maintainer: Joshua Branson
;; Keywords: autocorrect, org-mode, text-mode
;; Homepage: https://github.com/jbranso/autocorrect/blob/master/README.md
;;
;; This file is NOT part of GNU Emacs.
;;
;; Autocorrect is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; Autocorrect is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with Autocorrect.  If not, see <http://www.gnu.org/licenses/>.
;;
;;; Commentary:
;;
;; autocorrect automatically attempts to correct misspelled words as you type them. Currently only text-mode and org-mode are
;; supported.
;;
;; Installation and Activation
;; ---------------------------
;; See the corresponding sections in the readme at
;;
;;  https://github.com/jbranso/autocorrect/blob/master/README.md
;;
;;; Code:

(defvar autocorrect-regexp "^[a-zA-Z]+[;.,?!)\"]\\{0,3\\}$"
  "autocorrect-regexp is the regexp that makes sure the word is a word that we want to try to correct.
For example, my package should not try to correct a variable name.  So any word with any special
symbols in the middle of it or numbers, should not be corrected.  Here are some examples of words that will be corrected:

hello
pig,
dog;
cat?
hello...
why!?

Here are some words that will not be corrected:

h3ll0
w4y?
part-time
else$where!?
")

(defun autocorrect-is-word-correctable (string)
  (if (string= major-mode "org-mode")
      (and
       (string-match autocorrect-regexp string)
       (let (my/org-element-at-point)
         (setq my/org-element-at-point (car (org-element-at-point)))
         (not (or (string= "src-block" my/org-element-at-point)
                  (string= "node-property" my/org-element-at-point)
                  (string= "drawer" my/org-element-at-point)
                  (string= "keyword" my/org-element-at-point)
                  (string= "babel-call" my/org-element-at-point)
                  (string= "clock" my/org-element-at-point)
                  (string= "latex-environment" my/org-element-at-point)
                  (string= "table" my/org-element-at-point)
                  (string= "table-row" my/org-element-at-point)
                  (string= "export-snippet" my/org-element-at-point)
                  (string= "footnote-reference" my/org-element-at-point)
                  (string= "inline-babel-call" my/org-element-at-point)
                  (string= "inline-src-block" my/org-element-at-point)
                  (string= "link" my/org-element-at-point)
                  (string= "subscript" my/org-element-at-point)
                  (string= "superscript" my/org-element-at-point)
                  (string= "timestamp" my/org-element-at-point))))
    (string-match autocorrect-regexp string))))

(defun autocorrect-previous-word ()
  "Returns the previous word in the buffer."
  (interactive)
  (let (autocorrect-previous-word current-point)
    (setq current-point (point))
    (setq autocorrect-previous-word (progn
                                   (backward-word)
                                   (word-at-point)))
    (goto-char current-point)
    autocorrect-previous-word))

(defun autocorrect-flyspell-autocorrect-word ()
  "If the last entered character is SPC, then run flyspell-auto-correct-word on the last word "
  (interactive)
  (when (or
         (string= major-mode "org-mode")
         (string= major-mode "text-mode"))
    (let (previous-word previous-char current-point)
      (setq current-point (point))
      (setq previous-word (autocorrect-previous-word))
      ;; get the char before point.  For example, if you have just pressed the space bar, then the char before point is SPC.
      ;; Another example: if you have just pressed "h", then the char before point is "h".
      (setq previous-char
            (substring (buffer-substring (- (point) 1) (point)) 0))
      (when (and (string= previous-char " ")
                 ;; the string should just be alphanumeric characters, or it might have punctuation at the end.  Like "Hello?"
                 ;; (additional details)
                 ;; "I am a sentence," said me.
                 ;; "I don't care what you think," said Sally, "but if you would like, I can punch you in the face."
                 (autocorrect-is-word-correctable previous-word))
        (progn
          ;; if this word is already defined in abbrev-mode, then just expand it as a user-defined abbreviation.  Otherwise,
          ;; let flyspell expand it.
          (if (abbrev-symbol previous-word)
              (abbrev-insert previous-word)
            (flyspell-auto-correct-word))))
      (goto-char current-point))))

(defun autocorrect-add-autocorrect-hook ()
  "This function adds autocorrect-flyspell-autocorrect-word function to be run after post-self-insert-hook."
  (interactive)
  (add-hook 'post-self-insert-hook 'autocorrect-flyspell-autocorrect-word))

(defun autocorrect-remove-autocorrect-hook ()
  "This function adds autocorrect-flyspell-autocorrect-word function to be run after post-self-insert-hook."
  (interactive)
  (remove-hook 'post-self-insert-hook 'autocorrect-flyspell-autocorrect-word))

  (autocorrect-add-autocorrect-hook)

(define-key ctl-x-map "\C-i" #'autocorrect-ispell-word-the-abbrev)

(global-set-key (kbd "C-c C-x $") #'autocorrect-ispell-word-the-abbrev)

(defun autocorrect-ispell-word-the-abbrev (p)
  "Call `ispell-word', then create an abbrev for it.
With prefix P, create local abbrev. Otherwise it will
be global."
  (interactive "P")
  (let (bef aft)
    (save-excursion
      (while (progn
               (backward-word)
               (and (setq bef (thing-at-point 'word))
                    (not (ispell-word nil 'quiet)))))
      (setq aft (thing-at-point 'word)))
    (when (and aft bef (not (equal aft bef)))
      (setq aft (downcase aft))
      (setq bef (downcase bef))
      (define-abbrev
        (if p local-abbrev-table global-abbrev-table)
        bef aft)
      (message "\"%s\" now expands to \"%s\" %sally"
               bef aft (if p "loc" "glob")))))

(setq save-abbrevs 'silently)
(setq-default abbrev-mode t)

(defun autocorrect-add-word-to-dictionary (word)
  (interactive "sAdd Word to Dictionary: ")
  (define-abbrev global-abbrev-table word word))

(provide 'init-autocorrect)
;;; autocorrect.el ends here
