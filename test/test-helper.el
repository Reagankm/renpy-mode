;;; test-helper.el --- Helpers                       -*- lexical-binding: t; -*-

;;; Commentary:

;; test/test-helper.el is always loaded by ert-runner prior to running unit
;; tests.  If manual test run is necessary then this file has to be loaded
;; manually.

;;; Code:

(require 'ert)
(require 'renpy)

(defmacro with-temp-buffer-str (str &rest body)
  "Eval BODY within a buffer with containing STR."
  (declare (indent 1) (debug t))
  `(with-temp-buffer
     (insert ,str)
     (renpy-mode)
     (goto-char (point-min))
     ,@body))

(defmacro renpy-test-context (name code &optional expected)
  "Create an ERT test called NAME.
CODE is a code fragment where ‘|’ mark points where completion is
requested.  EXPECTED is the keyword symbol that
`renpy--completion-context' should return at the point.  EXPECTED can be
nil for no context."
  (declare (indent 1) (debug t))
  `(ert-deftest ,(intern (format "test-renpy-parse-context-%s" name)) ()
     (with-temp-buffer-str ,code
       (while (search-forward "|" nil t)
	 (delete-char -1)
	 (ert-info ((format "Context %s not found on line %d in: \n%s"
			    ,expected (line-number-at-pos) ,code))
	   (should (equal (renpy--parse-context) ,expected)))))))

(defmacro renpy-test-capf (name code &optional expected)
  "Create an ERT test called NAME.
The test runs `renpy-completion-at-point' within the CODE fragment,
expecting an EXPECTED candidate list.  In CODE ‘|’ marks the point where
completion is requested.  If EXPECTED is nil we assert that the CAPF
returns nil.

The test is executed twice: as is and with narrowing around the point."
  (declare (indent 1) (debug t))
  (let ((test-body
	 `(let* ((capf-ret (renpy-completion-at-point))
		 (prefix
		  (and capf-ret
		       (save-restriction
			 (widen)
			 (buffer-substring-no-properties
			  (nth 0 capf-ret)
			  (nth 1 capf-ret)))))
		 (table (nth 2 capf-ret))
		 (candidates (and capf-ret (all-completions prefix table))))
	    ,(if expected
		 `(progn
		    (should candidates)
		    (should (equal (sort candidates #'string<)
				   (sort expected #'string<))))
	       `(should (null candidates))))))
    `(ert-deftest ,(intern (format "test-renpy-capf-%s" name)) ()
       ;; Main test body - run the tests.
       (let ((expected (copy-sequence ',expected)))
	 (with-temp-buffer-str ,code
	   (search-forward "|" nil t)
	   (delete-char -1)
	   ,test-body))
       ;; Narrowing to the current point should not affect completion.
       (let ((expected (copy-sequence ',expected)))
	 (with-temp-buffer-str ,code
	   (search-forward "|" nil t)
	   (delete-char -1)
	   (narrow-to-region (point) (point))
	   ,test-body)))))

(defmacro renpy-test-bounds (name insert-text search-text bounds-func expected-value)
  "Create an ERT test NAME to check the bounds returned by BOUNDS-FUNC.
NAME is the test name.  INSERT-TEXT is the text to be inserted into the
buffer.  SEARCH-TEXT is the text to search for in the buffer.
BOUNDS-FUNC is the function used to find the bounds, and EXPECTED-VALUE
is the expected string within the bounds."
  (declare (indent 1) (debug t))
  `(ert-deftest ,name ()
     (with-temp-buffer
       (insert ,insert-text)
       (goto-char (point-min))
       (search-forward ,search-text)
       (let* ((bounds (,bounds-func))
              (beg (car bounds)) (end (cdr bounds))
              (result (buffer-substring-no-properties beg end)))
         (should (string= result ,expected-value))))))

;;; NOTE: Meant to be used manually.
(defun renpy-print-context-and-forward-char ()
  "Return the completion context symbol at point and move forward."
  (interactive nil renpy-mode)
  (unless (eq major-mode 'renpy-mode)
    (user-error "Not in `renpy-mode'"))
  (while t
    (message "Context: %s"(renpy--parse-context))
    (read-char)
    (forward-char)))

;;; test-helper.el ends here
