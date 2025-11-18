;;; renpy-font-lock-test.el ---                     -*- lexical-binding: t; -*-

;;; Commentary:

;; Font-lock unit tests.  Tests below focus on narrow font-lock cases.

;;; Code:

(require 'ert)
(require 'renpy-mode)

;; NOTE: ert-font-lock was only introduced in Emacs 30.
(when (>= emacs-major-version 30)
  (require 'ert-font-lock)
  ;; TODO: Atomic tests below should be accompanied with a single example file
  ;; imported from Ren'py.

;;;; Ren'py Keywords

  (ert-font-lock-deftest test-renpy-font-lock-basic renpy-mode
    "
label start:
# <- font-lock-keyword-face
#^^^^font-lock-keyword-face
#     ^^^^^ font-lock-function-name-face
    say \"Hello, World!\"

label .local_label:
#     ^^^^^^^^^^^^ font-lock-function-name-face
    pass
")

  (ert-font-lock-deftest test-renpy-font-lock-jump-call renpy-mode
    "
label start:
    call random_label
#   ^^^^ font-lock-keyword-face

    jump other_chapter
#   ^^^^ font-lock-keyword-face
")

  (ert-font-lock-deftest test-renpy-font-lock-image renpy-mode
    "
image eileen = \"eileen_happy.png\"
# <- font-lock-keyword-face
#^^^^ font-lock-keyword-face
#     ^^^^^^ font-lock-variable-name-face

image eileen happy wet = \"eileen_happy.png\"
# <- font-lock-keyword-face
#^^^^ font-lock-keyword-face
#     ^^^^^^ font-lock-variable-name-face
#            ^^^^^ font-lock-preprocessor-face
#                  ^^^ font-lock-preprocessor-face
")

  (ert-font-lock-deftest test-renpy-font-lock-show-hide renpy-mode
    "
show eileen happy with dissolve
# <- font-lock-keyword-face
#^^^              ^^^^ font-lock-keyword-face

show eileen happy at left with move
# <- font-lock-keyword-face
#^^^              ^^      ^^^^ font-lock-keyword-face

hide eileen with dissolve
# <- font-lock-keyword-face
#^^^        ^^^^ font-lock-keyword-face
")

  (ert-font-lock-deftest test-renpy-font-lock-show-layer renpy-mode
    "
show layer lay111 at left
# <- font-lock-keyword-face
#^^^ ^^^^^        ^^ font-lock-keyword-face
")

  (ert-font-lock-deftest test-renpy-font-lock-scene renpy-mode
    "
scene bg whitehouse with fade
# <- font-lock-keyword-face
#^^^^               ^^^^ font-lock-keyword-face
")

;;;; Python Keywords

  (ert-font-lock-deftest test-renpy-font-lock-python-keywords renpy-mode
  "
python:
    match x:
#   ^^^^^ font-lock-keyword-face
        case _:
#       ^^^^ font-lock-keyword-face
            print(\"Unknown case\")
"))

;;; renpy-font-lock-test.el ends here
