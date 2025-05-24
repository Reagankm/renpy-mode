;;; renpy-capf-collect-test.el ---                   -*- lexical-binding: t; -*-

;;; Commentary:

;; Completion candidate collection tests.

;;; Code:

(require 'ert)
(require 'renpy)

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

(ert-deftest test-renpy-completion-collect-images-atl ()
  (with-temp-buffer-str
      "
image eileen happy:
   \"eileen_happy\"

image black = \"#000\"

image animated_ariana_img:
    \"ariana\"
    pause 1.
    \"ariana_reverse\"
    pause 1.
    repeat
"
    (let ((images (renpy--collect-images)))
      (should (equal (length images) 3))
      (should (member "eileen happy" images))
      (should (member "black" images))
      (should (member "animated_ariana_img" images)))))

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

;;; renpy-capf-collect-test.el ends here
