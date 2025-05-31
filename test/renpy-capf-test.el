;;; renpy-capf-test.el ---                           -*- lexical-binding: t; -*-

;;; Commentary:

;; Completion-at-point end-to-end tests.

;;; Code:

(require 'ert)
(require 'renpy)

;;;; Local label completion

(renpy-test-capf none
  "
label start:
    pass

label other:
    pass

label .local:
    pass | # invalid context
")

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

label .local:
    pass

call st|
"
  ("start" ".local"))

(renpy-test-capf call-label-comment
  "
label start:
    pass

label .local:
    pass

call st| #comment
"
  ("start" ".local"))

(renpy-test-capf call-local-label
  "
label start:
    pass

label .local:
    pass

call .lo|
"
  ("start" ".local"))

(renpy-test-capf call-global-local-label
  "
label start:
    pass

label .local:
    pass

call start.lo|
"
  ("start" ".local"))

;;;; Local image completion

(renpy-test-capf show-image-no-whitespace
  "
image eileen happy = \"eileen_happy.png\"
image black = \"#000\"
image bg tiled = Tile(\"tile.jpg\")

show|
")

(renpy-test-capf show-image
  "
image eileen happy = \"eileen_happy.png\"
image black = \"#000\"
image bg tiled = Tile(\"tile.jpg\")

show |
"
  ("eileen happy" "black" "bg tiled"))

(renpy-test-capf show-image-tag
  "
image eileen = \"eileen.png\"
image eileen happy = \"eileen_happy.png\"
image eileen sad = \"eileen_sad.png\"
image eileen happy mud = \"eileen_sad.png\"

show eileen |
"
  ("eileen" "eileen happy" "eileen sad" "eileen happy mud"))

(renpy-test-capf hide-image
  "
image eileen happy = \"eileen_happy.png\"
image black = \"#000\"
image bg tiled = Tile(\"tile.jpg\")

hide |
"
  ("eileen happy" "black" "bg tiled"))

(renpy-test-capf scene-image
  "
image eileen happy = \"eileen_happy.png\"
image black = \"#000\"
image bg tiled = Tile(\"tile.jpg\")

scene |
"
  ("eileen happy" "black" "bg tiled"))

;;;; Local transform completion

(renpy-test-capf transform
  "transform left_to_right:
    xalign 0.
    linear 2 xalign 1.
    repeat

transform animated_ariana_disp:
    \"ariana\"
    pause 1.
    \"ariana_reverse\"
    pause 1.
    repeat

show eileen at |
"  ("left_to_right" "animated_ariana_disp"))

(renpy-test-capf transform-expression
  "transform left_to_right:
    xalign 0.

transform animated_ariana_disp:
    \"ariana_reverse\"
    pause 1.
    repeat

show expression \"my\" + \"image\" eileen at |
"  ("left_to_right" "animated_ariana_disp"))

;;; renpy-capf-test.el ends here
