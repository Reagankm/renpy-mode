;;; renpy-capf-test.el ---                           -*- lexical-binding: t; -*-

;;; Commentary:

;; Completion-at-point end-to-end tests.

;;; Code:

(require 'ert)
(require 'renpy)

;;;; Label completion.

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
  ("start"))

(renpy-test-capf call-label
  "
label start:
    pass

label .local:
    pass

call st|
"
  ("start"))

(renpy-test-capf call-screen
  "
screen ed(num):
    text \"Ed\"
    text \"Captain\"

screen kelly(num):
    text \"Kelly\"
    text \"First Officer\"

screen bortus:
    text \"Bortus\"
    text \"Second Officer\"

call screen |
" ("ed" "kelly" "bortus"))

(renpy-test-capf hide-screen
  "
screen ed(num):
    text \"Ed\"
    text \"Captain\"

screen kelly(num):
    text \"Kelly\"
    text \"First Officer\"

screen bortus:
    text \"Bortus\"
    text \"Second Officer\"

hide screen |
" ("ed" "kelly" "bortus"))

(renpy-test-capf call-label-comment
  "
label start:
    pass

label .local:
    pass

call st| #comment
"
  ("start"))

(renpy-test-capf call-local-label
  "
label start:
    pass

label .local:
    pass

call .lo|
"
  (".local"))

;; TODO: This is easy to support with a slightly smarter label collector: it
;; should emit both the usual dot-prefixed local labels and global ones.
;; (renpy-test-capf call-global-local-label
;;   "
;; label start:
;;     pass

;; label .local:
;;     pass

;; call start.lo|
;; "
;;   ("start.local"))

;;;; Local image completion.

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

(renpy-test-capf show-image-2
  "
image test1:
    \"test_one\"

image test2:
    \"test_two\"

show t|"
  ("test1" "test2"))

(renpy-test-capf show-image-tag
  "
image eileen = \"eileen.png\"
image eileen happy = \"eileen_happy.png\"
image eileen sad = \"eileen_sad.png\"
image eileen happy mud = \"eileen_sad.png\"

show eileen |
"
  ("eileen happy" "eileen sad" "eileen happy mud"))

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

;;;; Transform completion.

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

(renpy-test-capf show-layer-at-transform
  "transform left_to_right:
    xalign 0.

transform animated_ariana_disp:
    \"ariana_reverse\"
    pause 1.
    repeat

show layer testlayer at |
"  ("left_to_right" "animated_ariana_disp"))

(renpy-test-capf show-layer-at-transform-comma
  "transform left_to_right:
    xalign 0.

transform animated_ariana_disp:
    \"ariana_reverse\"
    pause 1.
    repeat

show layer testlayer at left_to_right, |
"  ("left_to_right" "animated_ariana_disp"))

(renpy-test-capf show-screen
  "
screen ed(num):
    text \"Ed\"
    text \"Captain\"

screen kelly(num):
    text \"Kelly\"
    text \"First Officer\"

screen bortus:
    text \"Bortus\"
    text \"Second Officer\"

show screen |
" ("ed" "kelly" "bortus"))

(renpy-test-capf scene-at-transform
  "transform left_to_right:
    xalign 0.

transform animated_ariana_disp:
    \"ariana_reverse\"
    pause 1.
    repeat

scene amg at |
"  ("left_to_right" "animated_ariana_disp"))

(renpy-test-capf scene-expression-at-transform
  "transform left_to_right:
    xalign 0.

transform animated_ariana_disp:
    \"ariana_reverse\"
    pause 1.
    repeat

scene amg at |
"  ("left_to_right" "animated_ariana_disp"))

(renpy-test-capf scene-at-transform-comma
  "transform left_to_right:
    xalign 0.

transform animated_ariana_disp:
    \"ariana_reverse\"
    pause 1.
    repeat

scene amg at transform1, |


"  ("left_to_right" "animated_ariana_disp"))

;;; renpy-capf-test.el ends here
