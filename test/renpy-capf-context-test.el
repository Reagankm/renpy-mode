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

;; This should be image context because "as" can be a partialially completed
;; image attribute.
(renpy-test-context show-image-2
  "
show img as|
" :image)

(renpy-test-context show-image-3
  "
show img at|
" :image)

(renpy-test-context scene-image
  "scene |" :image)

(renpy-test-context hide-image
  "hide |" :image)

(renpy-test-context at-transform
  "show img at |" :transform)

(renpy-test-context show-at-transform-comma
  "show img at left, |" :transform)

(renpy-test-context show-at-transform-comma-comma
  "show img at left, top, |" :transform)

(renpy-test-context show-expression-at-transform-comma
  "show expression img at left, |" :transform)

(renpy-test-context show-expression-at-transform-comma-comma
  "show expression img at left, top, |" :transform)

(renpy-test-context show-layer-at-transform
  "show layer layer1 at |" :transform)

(renpy-test-context show-layer-at-transform-comma
  "show layer layer1 at left, |" :transform)


;;;; Contexts that should not trigger completion
;;TODO: Some of these should eventually get completion support.

(renpy-test-context dot
  ".|")

;; TODO: Should be relatively easy to implement:
;; (renpy-test-context global-dot
;;   "jump global_label.|")

(renpy-test-context funcall-like
  "call (|")

(renpy-test-context invalid-context
  ") call |")

(renpy-test-context no-whitespace
  "call|")

(renpy-test-context not-keywords-1
  "bla bla |")

(renpy-test-context not-keywords-2
  "bla_bla |")

(renpy-test-context beginning-of-line
  "|")

(renpy-test-context jump-expression
  "jump expression |")

(renpy-test-context call-label-comment
  "#call |")

(renpy-test-context call-expression
  "call expression |")

(renpy-test-context call-label-present
  "call mylabel |")

(renpy-test-context call-label-open-string
  "\"call |")

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

(renpy-test-context call-label-init-python-comment
  "
init python: # comment
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

(renpy-test-context call-label-inline-python-2
  "
label start:
    # this is python
    $ var += (
        call |
    )
")

(renpy-test-context call-screen
  "
call screen |
")

(renpy-test-context hide-screen
  "
hide screen |
")

(renpy-test-context show-onlayer
		    "
show img onlayer |
")

(renpy-test-context show-behind
  "
show img behind |
")

(renpy-test-context show-zorder
  "
show img zorder |
")

(renpy-test-context show-as
  "
show img as |
")

(renpy-test-context show-screen
  "
show screen |
")

(renpy-test-context show-layer
  "
show layer |
")

;;; renpy-capf-context-test.el ends here
