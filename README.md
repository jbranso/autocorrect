## Autocorrect

This package automatically corrects your typing mistakes in whatever language you prefer, via piggybacking on top of flyspell-autocorrect-word.  Currently, Autocorrect only works for org-mode and text-mode, but hopefully someday soon it'll support all modes that are derived from text mode.  Autocorrect can potentially work for programming modes, but only in the comment areas. Talk to your Doctor and see if Autocorrect is right for you. :)

Autocorrect currently corrects some words incorrectly.  Like "mispelled" to "mi spelled".  But that's ok, because you can just as easily make autocorrect tell autocorrect to define a new abbreviation for you.  For example, if you have incorrectly spelled "mispelled", then you can use C-c C-x $ to define an abbrev for the misspelled word.  Then the next time you try to spell "mispelled", it will be correctly corrected to misspelled.
