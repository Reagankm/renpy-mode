;;; test-helper.el --- Helpers                       -*- lexical-binding: t; -*-

;;; Commentary:

;; test/test-helper.el is always loaded by ert-runner prior to running unit
;; tests.  If manual test run is necessary then this file has to be loaded
;; manually.

;;; Code:

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
CODE is a code fragment where ‘|’ marks the point where completion is
requested.  EXPECTED is the keyword symbol that
`renpy--completion-context' should return at the point.  If EXPECTED is
nil then no context should be found."
  (declare (indent 1) (debug t))
  `(ert-deftest ,(intern (format "test-renpy-completion-context-%s" name)) ()
     (with-temp-buffer-str ,code
       (search-forward "|" nil t)
       (delete-char -1)
       (should (equal (renpy--completion-context) ,expected)))))

(defmacro renpy-test-capf (name code &optional expected)
  "Create an ERT test called NAME.
The test runs `renpy-completion-at-point' within the CODE fragment,
expecting an EXPECTED candidate list.  In CODE ‘|’ marks the point where
completion is requested.  If EXPECTED is nil we assert that the CAPF
returns nil.

The test is executed twice: as is and with narrowing on the line where
the point is as this should affect the results."
  (declare (indent 1) (debug t))
  (let ((test-body
	 `(let ((candidates (renpy-completion-at-point)))
		,(if expected
		     `(progn
			(should candidates)
			(should (equal (sort (nth 2 candidates) #'string<)
				       (sort expected #'string<))))
		   `(should (null candidates))))))
  `(ert-deftest ,(intern (format "test-renpy-capf-%s" name)) ()
     ;; Main test body - run the tests.
     (let ((expected (copy-sequence ',expected)))
       (with-temp-buffer-str ,code
	 (search-forward "|" nil t)
	 (delete-char -1)
	 ,test-body))
     ;; Narrowing to the current line should not affect completion.
     (let ((expected (copy-sequence ',expected)))
       (with-temp-buffer-str ,code
	 (search-forward "|" nil t)
	 (delete-char -1)
	 (narrow-to-region (line-beginning-position)
			   (line-end-position))
	 ,test-body)))))

;;; test-helper.el ends here
