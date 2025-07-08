;;; renpy-context-test.el ---                        -*- lexical-binding: t; -*-

;;; Commentary:

;; Completion-at-point context checking functions.

;;; Code:

(require 'ert)
(require 'renpy)

;;;; Call statement.

(renpy-test-context call-label
  "
call |
call screen|
" :label)

(renpy-test-context call-with
  "
call screen myscreen(var=5) with |
call screen myscreen with |
" :transition)

(renpy-test-context call-no-context
  "
call (|
) call |
call|
#call |
call expression |
call mylabel |
\"call |
\"call |\"

python:
    # this is python
    call |

python:
    # this is python
    if True:
        call |

python in store:
    # this is python
    if True:
        call |

init python:
    # this is python
    call |

init python: # comment
    # this is python
    call |

init 111 python:
    # this is python
    call |

label start:
    # this is python
    $ call |

label start:
    # this is python
    $ var += (
        call |
    )

call screen |
")

;;;; Jump statement.

(renpy-test-context jump-label
  "jump |" :label)

(renpy-test-context jump-no-context
  "jump expression |")

;; TODO: Should be relatively easy to implement:
;; (renpy-test-context global-dot
;;   "jump global_label.|")

;;;; Show statement.

(renpy-test-context show-image
  "
show |
show img as|
show img at|
show screen|
show expression|
show img with|
" :image)

(renpy-test-context show-image-tag
  "
show img behind img1|
show img behind img1,|
show img behind |
" :image-tag)

(renpy-test-context show-behind-with
  "
show img behind img1 with dissolve |
")

(renpy-test-context show-with-transition
  "
show img with |
" :transition)

(renpy-test-context at-transform
  "
show img at |
show img at left, |
show img at left, top, |
show expression img at left, |
show expression img at left, top, |
show layer layer1 at |
show layer layer1 at left, |
" :transform)

(renpy-test-context show-no-context
  "
show img onlayer |
show img zorder |
show img as |
show layer |
")

;;;; Show screen statement.

(renpy-test-context show-screen
  "
show screen |
show screen scr1|
" :screen)

(renpy-test-context show-screen-no-context
  "
show screen scr1 |
show screen scr1, |
show screen scr1,|
")

;;;; Scene statement.

(renpy-test-context scene-image
  "scene |
scene img |
scene img at|
" :image)

(renpy-test-context scene-at
  "scene img at |" :transform)

(renpy-test-context scene-with
  "scene img with |
scene img with dissolve|" :transition)

(renpy-test-context scene-with-2
  "scene img with dissolve,|
scene img with dissolve |")

(renpy-test-context scene-behind
  "scene img behind |" :image-tag)

(renpy-test-context scene-expression
  "scene expression |")

;;;; Hide statement.

(renpy-test-context hide-no-context
  "
hide expression |
")

(renpy-test-context hide-image
  "hide |
hide screen|
hide expression|" :image)

(renpy-test-context hide-transition
  "hide img with |" :transition)

;;;; Hide screen statement.

(renpy-test-context hide-screen
  "
hide screen |
" :screen)

(renpy-test-context hide-screen-no-context
  "
hide screen scr1 |
hide screen scr1,|
hide screen scr1, |
")

;;;; With statement.

(renpy-test-context with
  "with |" :transition)

(renpy-test-context with-no-context
  "with dissolve,|")

;;;; Non-completing contexts.

(renpy-test-context no-context
  ".|
bla bla |
bla_bla |
|")

;;; renpy-context-test.el ends here
