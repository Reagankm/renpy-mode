;;; test-helper.el --- Helpers                       -*- lexical-binding: t; -*-

;; NOTE: test/test-helper.el is always loaded by ert-runner prior to running
;; unit tests. If manual test run is necessary then this file has to be loaded
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

(defmacro renpy-test-context (name code expected)
  "Create an ERT test called NAME.
CODE is a code fragment where ‘|’ marks the point where completion is
requested. EXPECTED is the keyword symbol that
`renpy--completion-context' should return."
  (declare (indent 1) (debug t))
  `(ert-deftest ,(intern (format "test-renpy-completion-context-%s" name)) ()
     (with-temp-buffer-str ,code
       (search-forward "|" nil t)
       (delete-char -1)
       (should (equal (renpy--completion-context) ,expected)))))

(defmacro renpy-test-capf (name code expected-cands)
  "Run CAPF in CODE fragment, expect EXPECTED-CANDS list.
In CODE ‘|’ marks the point where completion is requested. If
EXPECTED-CANDS is nil we assert that the CAPF returns nil."
  (declare (indent 1) (debug t))
  `(ert-deftest ,(intern (format "test-renpy-completion-capf-%s" name)) ()
     (with-temp-buffer-str ,code
       (search-forward "|" nil t)
       (delete-char -1)
       (let ((capf (renpy-completion-at-point)))
         ,(if expected-cands
              `(progn
                 (should capf)
                 (should (equal (sort (nth 2 capf) #'string<)
                                (sort ',expected-cands #'string<))))
            `(should (null capf)))))))

;;; test-helper.el ends here
