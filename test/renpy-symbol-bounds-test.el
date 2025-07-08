;;; renpy-symbol-bounds-test.el ---             -*- lexical-binding: t; -*-

;;; Commentary:

;; Test symbol at point bounds functions

;;; Code:

(require 'ert)
(require 'renpy)

(renpy-test-bounds test-renpy-find-symbol-bounds
  "   test_symbol   "
  "test"
  (lambda () (renpy--find-symbol-bounds "w_"))
  "test_symbol")

(renpy-test-bounds test-renpy-find-symbol-bounds-2
  "   test_symbol   "
  "test"
  (lambda () (renpy--find-symbol-bounds "w"))
  "test")

(renpy-test-bounds test-renpy-find-symbol-bounds-leading-punctuation
  "   _leadingSymbol   "
  "_leading"
  (lambda () (renpy--find-symbol-bounds "w_"))
  "_leadingSymbol")

(renpy-test-bounds test-renpy-find-symbol-bounds-single-char
  "x"
  "x"
  (lambda () (renpy--find-symbol-bounds "w_"))
  "x")

(renpy-test-bounds test-renpy-find-image-bounds-1
  "show example image"
  "example"
  renpy--find-image-bounds
  "example image")

(renpy-test-bounds test-renpy-find-image-bounds-2
  "show example image with t"
  "example"
  renpy--find-image-bounds
  "example image")

(renpy-test-bounds test-renpy-find-image-bounds-3
  "show example image as smth"
  "example"
  renpy--find-image-bounds
  "example image")

(renpy-test-bounds test-renpy-find-image-bounds-4
  "show layertest at side_image_scale"
  "show "
  renpy--find-image-bounds
  "layertest")

(renpy-test-bounds test-renpy-find-image-bounds-keyword-eol
  "show "
  " "
  renpy--find-image-bounds
  "")

(renpy-test-bounds test-renpy-find-image-bounds-char
  "x"
  ""
  renpy--find-image-bounds
  "x")

(renpy-test-bounds test-renpy-find-image-bounds-chars
  "x y z"
  ""
  renpy--find-image-bounds
  "x y z")

(renpy-test-bounds test-renpy-find-image-bounds-immediate-keyword
  "showscene"
  "showscene"
  renpy--find-image-bounds
  "showscene")

(provide 'renpy-symbol-bounds-test)
;;; renpy-symbol-bounds-test.el ends here
