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
  "bla bla |" nil)

;;;;; Comment and string contexts

(renpy-test-context call-label-comment
  "#call |" nil)

(renpy-test-context call-label-string
  "\"call |\" " nil)

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

;;;; Local image completion

(ert-deftest test-renpy-completion-collect-images ()
  (with-temp-buffer-str
"
image eileen happy = \"eileen_happy.png\"
image black = \"#000\"
image bg tiled = Tile(\"tile.jpg\")

image eileen happy question = VBox(
    \"question.png\",
    \"eileen_happy.png\",
    )
"
    (let ((images (renpy--collect-images)))
      (should (equal (length images) 4))
      (should (member "eileen happy" images))
      (should (member "black" images))
      (should (member "bg tiled" images))
      (should (member "eileen happy question" images)))))

(renpy-test-capf show-image
  "
image eileen happy = \"eileen_happy.png\"
image black = \"#000\"
image bg tiled = Tile(\"tile.jpg\")

show |
"
  ("eileen happy" "black" "bg tiled"))

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

(ert-deftest test-renpy-completion-collect-transforms ()
  (with-temp-buffer-str
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
"
    (let ((transforms (renpy--collect-transforms)))
      (should (equal (length transforms) 2))
      (should (member "left_to_right" transforms))
      (should (member "animated_ariana_disp" transforms)))))

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

;;; renpy-completion-test.el ends here
