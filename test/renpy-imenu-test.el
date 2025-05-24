;;; renpy-imenu-test.el ---                                -*- lexical-binding: t; -*-

;;; Commentary:

;; Imenu unit tests

;;; Code:

(require 'ert)
(require 'renpy)

;; TODO: Figure out proper imenu names.

(ert-deftest test-renpy-imenu-basic ()
  (with-temp-buffer-str
      "
# comment
label start:
    say \"This is a test\"
"
    (let ((index-alist (funcall imenu-create-index-function)))
      (should (equal (length index-alist) 1))
      (should (alist-get "start" index-alist nil nil #'string-equal)))))

(ert-deftest test-renpy-imenu-multiple ()
  (with-temp-buffer-str
      "
# comment
label first:
    say \"first label\"

label second_label:
    say \"second label\"

label .local_label:
    say \"local label\"

label label_with_params(a):
    say \"paremetrized label\"

"
    (let ((index-alist (funcall imenu-create-index-function)))
      (should (equal (length index-alist) 4))
      (should (alist-get "first" index-alist nil nil #'string-equal))
      (should (alist-get "second_label" index-alist nil nil #'string-equal))
      (should (alist-get ".local_label" index-alist nil nil #'string-equal))
      (should (alist-get "label_with_params" index-alist nil nil #'string-equal)))))

(ert-deftest test-renpy-imenu-style-transform ()
  (with-temp-buffer-str
      "
style button:
    background \"button.png\"

transform fade_in:
    alpha 0.0
    linear 0.5 alpha 1.0
"
    (let* ((index-alist (funcall imenu-create-index-function))
	  (style-alist (alist-get "/style" index-alist nil nil #'string-equal))
	  (transform-alist (alist-get "/transform" index-alist nil nil #'string-equal)))
      (should (equal (length index-alist) 2))
      (should style-alist)
      (should transform-alist)
      (should (alist-get "button" style-alist nil nil #'string-equal))
      (should (alist-get "fade_in" transform-alist nil nil #'string-equal)))))

(ert-deftest test-renpy-imenu-screen-image ()
  (with-temp-buffer-str
      "
screen main_menu():
    textbutton \"Start Game\" action Start()

image eileen happy = \"eileen_happy.png\"
"
    (let* ((index-alist (funcall imenu-create-index-function))
	   (screen-alist (alist-get "/screen" index-alist nil nil #'string-equal))
	   (image-alist (alist-get "/image" index-alist nil nil #'string-equal)))
      (should (equal (length index-alist) 2))
      (should screen-alist)
      (should image-alist)
      (should (alist-get "main_menu" screen-alist nil nil #'string-equal))
      (should (alist-get "eileen" image-alist nil nil #'string-equal)))))

(ert-deftest test-renpy-imenu-class-function ()
  (with-temp-buffer-str
      "
init python:
    class MyClass(object):
        def method(self):
            pass

def my_function(param):
    return param
"
    (let* ((index-alist (funcall imenu-create-index-function))
	   (class-alist (alist-get "/class" index-alist nil nil #'string-equal))
	   (function-alist (alist-get "/function" index-alist nil nil #'string-equal)))
      (should (equal (length index-alist) 2))
      (should class-alist)
      (should function-alist)
      (should (alist-get "MyClass" class-alist nil nil #'string-equal))
      (should (alist-get "my_function" function-alist nil nil #'string-equal)))))

(ert-deftest test-renpy-imenu-define-default ()
  (with-temp-buffer-str
      "
define character = Character('Eileen')
default points = 0
"
    (let* ((index-alist (funcall imenu-create-index-function))
	   (define-alist (alist-get "/define" index-alist nil nil #'string-equal))
	   (default-alist (alist-get "/default" index-alist nil nil #'string-equal)))
      (should (equal (length index-alist) 2))
      (should (alist-get "character" define-alist nil nil #'string-equal))
      (should (alist-get "points" default-alist nil nil #'string-equal)))))


;;; renpy-imenu-test.el ends here
