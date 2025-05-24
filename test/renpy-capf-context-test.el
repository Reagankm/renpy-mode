;;; renpy-capf-context-test.el ---                        -*- lexical-binding: t; -*-

;;; Commentary:

;; Completion-at-point context checking functions.

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

;;;; Contexts that should not trigger completion

(renpy-test-context dot
  ".|")

;; TODO: should be relatively easy to implement
;; (renpy-test-context global-dot
;;   "jump global_label.|")

(renpy-test-context funcall-like
  "call (|")

(renpy-test-context no-whitespace
  "call|")

(renpy-test-context not-keywords-1
  "bla bla |")

(renpy-test-context not-keywords-2
  "bla_bla |")

(renpy-test-context beginning-of-line
  "|")

(renpy-test-context call-label-comment
  "#call |")

(renpy-test-context call-label-string
  "\"call |\" ")

(renpy-test-context call-label-python-1
  "
python:
    # this is python
    call |
")

(renpy-test-context call-label-python-2
  "
python:
    # this is python
    if True:
        call |
")

(renpy-test-context call-label-python-3
  "
python in store:
    # this is python
    if True:
        call |
")

(renpy-test-context call-label-init-python
  "
init python:
    # this is python
    call |
")

(renpy-test-context call-label-init-priority-python
  "
init 111 python:
    # this is python
    call |
")

(renpy-test-context call-label-inline-python
  "
label start:
    # this is python
    $ call |
")

;;; renpy-capf-context-test.el ends here
