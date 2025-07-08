;;; renpy-symbol-collect-test.el ---                   -*- lexical-binding: t; -*-

;;; Commentary:

;; Symbol collection tests.

;;; Code:

(require 'ert)
(require 'renpy)

(ert-deftest test-renpy-collect-labels ()
  (with-temp-buffer-str
      "
label start:
    pass

label global_label:
   pass

label .local_label:
   pass
"
    (let ((labels (renpy--collect-labels-cached nil)))
      (should (equal (length labels) 3))
      (should (alist-get "start" labels nil nil #'equal))
      (should (alist-get "global_label" labels nil nil #'equal))
      (should (alist-get ".local_label" labels nil nil #'equal)))))


(ert-deftest test-renpy-collect-images ()
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
    (let ((images (renpy--collect-images-cached nil)))
      (should (equal (length images) 4))
      (should (alist-get "eileen happy" images nil nil #'equal))
      (should (alist-get "black" images nil nil #'equal))
      (should (alist-get "bg tiled" images nil nil #'equal))
      (should (alist-get "eileen happy question" images nil nil #'equal)))))

(ert-deftest test-renpy-collect-images-atl ()
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
    (let ((images (renpy--collect-images-cached nil)))
      (should (equal (length images) 3))
      (should (alist-get "eileen happy" images nil nil #'equal))
      (should (alist-get "black" images nil nil #'equal))
      (should (alist-get "animated_ariana_img" images nil nil #'equal)))))

(ert-deftest test-renpy-collect-transforms ()
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
    (let ((transforms (renpy--collect-transforms-cached nil)))
      (should (equal (length transforms) 2))
      (should (alist-get "left_to_right" transforms nil nil #'equal))
      (should (alist-get "animated_ariana_disp" transforms nil nil #'equal)))))

(ert-deftest test-renpy-collect-screens ()
  (with-temp-buffer-str
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
"
    (let ((screens (renpy--collect-screens-cached nil)))
      (should (equal (length screens) 3))
      (should (alist-get "ed" screens nil nil #'equal))
      (should (alist-get "kelly" screens nil nil #'equal))
      (should (alist-get "bortus" screens nil nil #'equal)))))

;;; renpy-symbol-collect-test.el ends here
