;;; renpy-completion-test.el ---                        -*- lexical-binding: t; -*-

;;; Code:

(require 'ert)
(require 'renpy)

;;;; Completion contexts

(renpy-test-context call-label
  "call |" :label)

(renpy-test-context jump-label
  "jump |" :label)

(renpy-test-context show-image
  "show |" :image)

(renpy-test-context scene-image
  "scene |" :image)

(renpy-test-context hide-image
  "hide |" :image)

(renpy-test-context at-transform
  "at |" :transform)

(renpy-test-context default
  "bla bla |" :none)

;;;; Local label completion

(ert-deftest test-renpy-completion-collect-labels ()
  (with-temp-buffer-str
      "
label start:
    pass

label global_label:
   pass

label .local_label:
   pass
"
    (let ((labels (renpy--collect-labels)))
      (should (equal (length labels) 3))
      (should (member "start" labels))
      (should (member "global_label" labels))
      (should (member ".local_label" labels)))))

(renpy-test-capf none
  "
label start:
    pass

label other:
    pass

label .local:
    pass | # invalid context
"
  ())

(renpy-test-capf jump-label
  "
label start:
    pass

label other:
    pass

label .local:
    pass

jump st|
"
  ("start" "other" ".local"))

(renpy-test-capf call-label
  "
label start:
    pass

label other:
    pass

label .local:
    pass

call st|
"
  ("start" "other" ".local"))

;;; renpy-completion-test.el ends here
