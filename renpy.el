;;; renpy.el --- Major mode for editing Ren'Py files -*- lexical-binding: t; -*-

;; Copyright (C) 2003-2013
;;   Free Software Foundation, Inc.
;; Copyright (C) 2018-2019
;;   Billy Wade
;; Copyright (C) 2020
;;   Reagan Middlebrook
;; Copyright (C) 2023
;;   Morgan Willcock

;; Author: Dave Love <fx@gnu.org>, PyTom <pytom@bishoujo.us>
;; Keywords: languages
;; Maintainer: Reagan Middlebrook <reagankm@gmail.com>
;; Package-Requires: ((emacs "27.1"))
;; URL: https://github.com/Reagankm/renpy-mode
;; Version: 0.3

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; A major mode for Ren'Py based on Dave Love's python.el.

;;; Code:

(require 'imenu)

(defgroup renpy nil
  "Major mode for editing Ren'Py files."
  :tag "Ren'Py"
  :prefix "renpy-"
  :group 'languages
  :link '(emacs-commentary-link "renpy"))

;;;###autoload
(add-to-list 'auto-mode-alist '("\\.rpym?\\'" . renpy-mode))

;;;; Search patterns

(defmacro renpy-rx (&rest regexps)
  "Extended version of `rx' for translation of form REGEXPS."
  `(rx-let (;; User defined names.
	    (name
	     (seq symbol-start
		  (or alpha "_")
		  (0+ (or alphanumeric "_"))
		  symbol-end))
	    (label-name
	     (seq (optional ".") name))
	    (image-name
	     (seq symbol-start
		  (1+ (or alphanumeric "_"))
		  symbol-end))
	    ;; Labels.	It is not a logical error if the label definition
	    ;; doesn't begin at the start of the line.
	    (label-keyword
	     (seq line-start (0+ space) "label" symbol-end))
	    ;; Screens.
	    (screen-keyword
	     (seq line-start "screen" symbol-end))
	    ;; Styles.
	    (style-keyword
	     (seq line-start "style" symbol-end))
	    ;; Transforms
	    (transform-keyword
	     (seq line-start "transform" symbol-end))
	    ;; Images.
	    (image-keyword
	     (seq line-start "image" symbol-end))
	    ;; Define and default. Both allow indentation for use in explicit
	    ;; init blocks or within a screen.
	    (define-keyword
	     (seq line-start (0+ space) "define" symbol-end))
	    (default-keyword
	     (seq line-start (0+ space) "default" symbol-end))
	    ;; Init.
	    (init-keyword
	     (seq line-start "init" symbol-end))
	    (init-argument
	     (seq symbol-start (or "hide" "in" "offset" "python") symbol-end))
	    ;; Keywords from sphinx/source/keywords.py.
	    (keyword
	     (seq symbol-start
		  (or "$" "False" "IF" "None" "True" "add" "always" "and"
		      "animation" "areapicker" "as" "assert" "async" "at"
		      "attribute" "auto" "await" "bar" "behind" "block" "break"
		      "button" "call" "camera" "choice" "circles" "class"
		      "clear" "clockwise" "contains" "continue"
		      "counterclockwise" "def" "default" "define" "del"
		      "dismiss" "drag" "draggroup" "elif" "else" "event"
		      "except" "expression" "finally" "fixed" "for" "frame"
		      "from" "function" "global" "grid" "group" "has" "hbox"
		      "hide" "hotbar" "hotspot" "if" "image" "imagebutton"
		      "imagemap" "import" "in" "index" "init" "input" "is"
		      "jump" "key" "knot" "label" "lambda" "layeredimage" "menu"
		      "monologue" "mousearea" "music" "nearrect" "new"
		      "nointeract" "nonlocal" "not" "null" "nvl" "offset" "old"
		      "on" "onlayer" "or" "parallel" "pass" "pause" "play"
		      "python" "queue" "raise" "repeat" "return" "rpy" "scene"
		      "screen" "show" "showif" "side" "sound" "stop" "strings"
		      "style" "sustain" "tag" "take" "testcase" "text"
		      "textbutton" "time" "timer" "transclude" "transform"
		      "translate" "try" "use" "vbar" "vbox" "viewport" "voice"
		      "vpgrid" "while" "window" "with" "yield" "zorder")
		  symbol-end))
	    ;; Classes and functions from
	    ;; https://www.renpy.org/doc/html/py-function-class-index.html.
	    ;; Note: Any name containing a "." was ommited to try and keep the
	    ;; highlighting consistent with the use of other python modules.
	    ;; Variables were not included for the same reason.
	    (class-or-function
	     (seq symbol-start
		  (or "AddToSet" "AlphaBlend" "AlphaDissolve" "AlphaMask"
		      "AnimatedValue" "At" "Attribute" "AudioData"
		      "AudioPositionValue" "add" "BarValue" "Borders"
		      "BrightnessMatrix" "Call" "CaptureFocus" "Character"
		      "ClearFocus" "Color" "ColorizeMatrix" "ComposeTransition"
		      "Composite" "Condition" "ConditionSwitch" "Confirm"
		      "ContrastMatrix" "Crop" "CropMove" "DictInputValue"
		      "DictValue" "DisableAllInputValues" "Dissolve" "Drag"
		      "DragGroup" "DynamicDisplayable" "DynamicImage" "Editor"
		      "EndReplay" "Fade" "FieldInputValue" "FieldValue"
		      "FileAction" "FileCurrentPage" "FileCurrentScreenshot"
		      "FileDelete" "FileJson" "FileLoad" "FileLoadable"
		      "FileNewest" "FilePage" "FilePageName"
		      "FilePageNameInputValue" "FilePageNext" "FilePagePrevious"
		      "FileSave" "FileSaveName" "FileScreenshot" "FileSlotName"
		      "FileTakeScreenshot" "FileTime" "FileUsedSlots" "Fixed"
		      "Flatten" "FontGroup" "Frame" "Function" "Gallery"
		      "GamepadCalibrate" "GamepadExists" "GetCharacterVolume"
		      "GetFocusRect" "GetTooltip" "Grid" "HBox" "Help" "Hide"
		      "HideInterface" "HistoryEntry" "HueMatrix"
		      "IdentityMatrix" "If" "Image" "ImageDissolve" "InputValue"
		      "InvertMatrix" "InvertSelected" "Jump" "Language"
		      "LayeredImage" "LayeredImageProxy" "Lexer" "Live2D"
		      "MainMenu" "Matrix" "MixerValue" "Model"
		      "MouseDisplayable" "MouseMove" "MoveTransition" "Movie"
		      "MultiPersistent" "MultipleTransition" "MusicRoom"
		      "NoRollback" "Notify" "Null" "NullAction" "nvl_clear"
		      "nvl_hide" "nvl_menu" "nvl_show" "OffsetMatrix"
		      "OpacityMatrix" "OpenDirectory" "OpenURL"
		      "ParameterizedText" "Pause" "PauseAudio" "Pixellate"
		      "Placeholder" "Play" "PlayCharacterVoice" "Preference"
		      "PushMove" "Queue" "QueueEvent" "QuickLoad" "QuickSave"
		      "Quit" "RemoveFromSet" "Replay" "RestartStatement"
		      "Return" "RollForward" "Rollback" "RollbackToIdentifier"
		      "RotateMatrix" "remap" "Sample" "SaturationMatrix"
		      "ScaleMatrix" "ScreenVariableInputValue"
		      "ScreenVariableValue" "Screenshot" "Scroll" "SelectedIf"
		      "SensitiveIf" "SepiaMatrix" "SetCharacterVolume" "SetDict"
		      "SetField" "SetLocalVariable" "SetMixer" "SetMute"
		      "SetScreenVariable" "SetVariable" "SetVoiceMute" "Show"
		      "ShowMenu" "ShowTransient" "ShowingSwitch" "SideImage"
		      "Skip" "SlottedNoRollback" "SnowBlossom" "Solid" "Sprite"
		      "SpriteManager" "Start" "StaticValue" "Stop" "Style"
		      "StylePreference" "Swing" "Text" "Tile" "TintMatrix"
		      "ToggleDict" "ToggleField" "ToggleFocus"
		      "ToggleLocalVariable" "ToggleMute" "ToggleScreen"
		      "ToggleScreenVariable" "ToggleSetMembership"
		      "ToggleVariable" "ToggleVoiceMute" "Tooltip" "Transform"
		      "translate_define" "translate_font" "VBox"
		      "VariableInputValue" "VariableValue" "VoiceReplay"
		      "voice_can_replay" "voice_replay" "voice_sustain" "With"
		      "XScrollValue" "YScrollValue" "_" "__" "_get_voice_info"
		      "_p" "_window_hide" "_window_show")
		  symbol-end))
	    (transform-property
	     (seq word-start
		  (or "additive" "align" "alignaround" "alpha" "anchor" "angle"
		      "around" "blend" "blur" "corner1" "corner2" "crop"
		      "crop_relative" "delay" "events" "fit" "matrixanchor"
		      "matrixcolor" "matrixtransform" "maxsize" "mesh"
		      "mesh_pad" "nearest" "offset" "perspective" "pos" "radius"
		      "rotate" "rotate_pad" "shader" "size" "subpixel"
		      "transform_anchor" "xalign" "xanchor" "xcenter" "xoffset"
		      "xpan" "xpos" "xsize" "xtile" "xycenter" "xysize" "xzoom"
		      "yalign" "yanchor" "ycenter" "yoffset" "ypan" "ypos"
		      "ysize" "ytile" "yzoom" "zoom" "zpos")
		  symbol-end))
	    ;; User Interface statements from
	    ;; https://www.renpy.org/doc/html/screens.html#common-properties.
	    (ui-statement
	     (seq word-start
		  (or "at" "default_focus" "id" "style" "style_prefix"
		      "style_group" "style_suffix" "focus" "tooltip" "arguments"
		      "properties")
		  word-end))
	    ;; Style properties from
	    ;; https://www.renpy.org/doc/html/std-style-property-index.html.
	    (style-prefix
	     (seq word-start
		  (or "idle" "hover" "selected" "insensitive" "selected_idle"
		      "selected_hover" "selected_insensitive")
		  ?_
		  word-start))
	    (style-prefix-text
	     (seq symbol-start "text_" word-start))
	    (style-prefix-scrollbar
	     (seq symbol-start (optional ?v) "scrollbar_" word-start))
	    (style-prefix-side
	     (seq symbol-start "side_" word-start))
	    (style-prefix-viewport
	     (seq symbol-start "viewport_" word-start))
	    (style-position
	     (seq word-start
		  (or "alt" "xpos" "ypos" "pos" "xanchor" "yanchor" "anchor"
		      "xalign" "yalign" "align" "xcenter" "ycenter" "xoffset"
		      "yoffset" "offset" "xmaximum" "ymaximum" "maximum"
		      "xminimum" "yminimum" "minimum" "xsize" "ysize" "xysize"
		      "xfill" "yfill" "area" "mipmap")
		  symbol-end))
	    (style-text
	     (seq word-start
		  (or "antialias" "adjust_spacing" "altruby_style" "black_color"
		      "bold" "caret" "color" "first_indent" "font" "size"
		      "italic" "justify" "kerning" "language" "layout"
		      "line_leading" "line_overlap_split" "line_spacing"
		      "min_width" "newline_indent" "outlines" "style"
		      "outline_scaling" "rest_indent" "ruby_style"
		      "slow_abortable" "slow_cps" "slow_cps_multiplier"
		      "strikethrough" "text_align" "underline"
		      "hyperlink_functions" "vertical" "hinting")
		  symbol-end))
	    (style-window
	     (seq word-start
		  (or "background" "foreground" "left_padding" "right_padding"
		      "xpadding" "top_padding" "bottom_padding" "ypadding"
		      "padding" "size_group" "modal")
		  symbol-end))
	    (style-button
	     (seq word-start
		  (or "child" "hover_sound" "activate_sound" "mouse"
		      "focus_mask" "keyboard_focus" "key_events")
		  symbol-end))
	    (style-bar
	     (seq word-start
		  (or "bar_vertical" "bar_invert" "bar_resizing" "left_gutter"
		      "right_gutter" "top_gutter" "bottom_gutter" "left_bar"
		      "right_bar" "top_bar" "bottom_bar" "base_bar" "thumb"
		      "thumb_shadow" "thumb_offset" "mouse" "unscrollable"
		      "keyboard_focus")
		  symbol-end))
	    (style-box
	     (seq word-start
		  (or "spacing" "first_spacing" "box_reverse" "box_wrap"
		      "box_wrap_spacing" "order_reverse")
		  symbol-end))
	    (style-grid
	     (seq word-start
		  (or "spacing" "xspacing" "yspacing")
		  symbol-end))
	    (style-fixed
	     (seq word-start
		  (or "fit_first" "xfit" "yfit")
		  symbol-end))
	    (style-margin
	     (seq word-start
		  (or "left_margin" "right_margin" "xmargin" "top_margin"
		      "bottom_margin" "ymargin" "margin")
		  symbol-end))
	    ;; Warper functions from
	    ;; https://www.renpy.org/doc/html/atl.html#warpers.
	    (warper
	     (seq symbol-start
		  (or "pause" "linear" "ease" "easein" "easeout"

		      "ease_back" "ease_bounce" "ease_circ" "ease_cubic"
		      "ease_elastic" "ease_expo" "ease_quad" "ease_quart"
		      "ease_quint" "easein_back" "easein_bounce" "easein_circ"
		      "easein_cubic" "easein_elastic" "easein_expo"
		      "easein_quad" "easein_quart" "easein_quint"
		      "easeout_back" "easeout_bounce" "easeout_circ"
		      "easeout_cubic" "easeout_elastic" "easeout_expo"
		      "easeout_quad" "easeout_quart" "easeout_quint")
		  symbol-end)))
     (rx ,@regexps)))

;;;; Font lock

(defvar renpy-font-lock-keywords
  `(,(rx symbol-start
	 ;; From v 2.7 Keywords reference.
	 ;; def and class dealt with separately below
	 (or "and" "as" "assert" "break" "continue" "del" "elif" "else"
	     "except" "exec" "finally" "for" "from" "global" "if"
	     "import" "in" "is" "lambda" "not" "or" "pass" "print"
	     "raise" "return" "try" "while" "with" "yield"
	     ;; Not real keywords, but close enough to be fontified as such
	     "self" "True" "False"
	     ;; Python 3
	     "nonlocal")
	 symbol-end)
    (,(rx symbol-start "None" symbol-end)	; see Keywords in 2.7 manual
     . font-lock-constant-face)
    ;; Definitions
    (,(rx symbol-start (group "class") (1+ space) (group (1+ (or word ?_))))
     (1 font-lock-keyword-face) (2 font-lock-type-face))
    (,(rx symbol-start (group "def") (1+ space) (group (1+ (or word ?_))))
     (1 font-lock-keyword-face) (2 font-lock-function-name-face))
    ;; Top-level assignments are worth highlighting.
    (,(rx line-start (group (1+ (or word ?_))) (0+ space)
	  (opt (or "+" "-" "*" "**" "/" "//" "&" "%" "|" "^" "<<" ">>")) "=")
     (1 font-lock-variable-name-face))
    ;; Decorators.
    (,(rx line-start (* (any " \t")) (group "@" (1+ (or word ?_))
					    (0+ "." (1+ (or word ?_)))))
     (1 font-lock-type-face))
    ;; Built-ins.  (The next three blocks are from
    ;; `__builtin__.__dict__.keys()' in Python 2.7)  These patterns
    ;; are debatable, but they at least help to spot possible
    ;; shadowing of builtins.
    (,(rx symbol-start (or
	  ;; exceptions
	  "ArithmeticError" "AssertionError" "AttributeError"
	  "BaseException" "DeprecationWarning" "EOFError"
	  "EnvironmentError" "Exception" "FloatingPointError"
	  "FutureWarning" "GeneratorExit" "IOError" "ImportError"
	  "ImportWarning" "IndentationError" "IndexError" "KeyError"
	  "KeyboardInterrupt" "LookupError" "MemoryError" "NameError"
	  "NotImplemented" "NotImplementedError" "OSError"
	  "OverflowError" "PendingDeprecationWarning" "ReferenceError"
	  "RuntimeError" "RuntimeWarning" "StandardError"
	  "StopIteration" "SyntaxError" "SyntaxWarning" "SystemError"
	  "SystemExit" "TabError" "TypeError" "UnboundLocalError"
	  "UnicodeDecodeError" "UnicodeEncodeError" "UnicodeError"
	  "UnicodeTranslateError" "UnicodeWarning" "UserWarning"
	  "ValueError" "Warning" "ZeroDivisionError"
	  ;; Python 2.7
	  "BufferError" "BytesWarning" "WindowsError")
	  symbol-end)
     . font-lock-type-face)
    (,(rx (or line-start (not (any ". \t"))) (* (any " \t")) symbol-start
	  (group (or
	  ;; callable built-ins, fontified when not appearing as
	  ;; object attributes
	  "abs" "all" "any" "apply" "basestring" "bool" "buffer" "callable"
	  "chr" "classmethod" "cmp" "coerce" "compile" "complex"
	  "copyright" "credits" "delattr" "dict" "dir" "divmod"
	  "enumerate" "eval" "execfile" "exit" "file" "filter" "float"
	  "frozenset" "getattr" "globals" "hasattr" "hash" "help"
	  "hex" "id" "input" "int" "intern" "isinstance" "issubclass"
	  "iter" "len" "license" "list" "locals" "long" "map" "max"
	  "min" "object" "oct" "open" "ord" "pow" "property" "quit"
	  "range" "raw_input" "reduce" "reload" "repr" "reversed"
	  "round" "set" "setattr" "slice" "sorted" "staticmethod"
	  "str" "sum" "super" "tuple" "type" "unichr" "unicode" "vars"
	  "xrange" "zip"
	  ;; Python 2.7.
	  "bin" "bytearray" "bytes" "format" "memoryview" "next" "print"))
	  symbol-end)
     (1 font-lock-builtin-face))
    (,(rx symbol-start (or
	  ;; other built-ins
	  "True" "False" "None" "Ellipsis"
	  "_" "__debug__" "__doc__" "__import__" "__name__" "__package__")
	  symbol-end)
     . font-lock-builtin-face)
    ;; Ren'Py 8.0.3
    (,(renpy-rx (group label-keyword) (1+ space) (group label-name))
     (1 font-lock-keyword-face) (2 font-lock-function-name-face))
    (,(renpy-rx (group screen-keyword) (1+ space) (group name))
     (1 font-lock-keyword-face) (2 font-lock-function-name-face))
    (,(renpy-rx (group style-keyword) (1+ space) (group name))
     (1 font-lock-keyword-face) (2 font-lock-variable-name-face))
    (,(renpy-rx (group transform-keyword) (1+ space) (group name))
     (1 font-lock-keyword-face) (2 font-lock-function-name-face))
    (,(renpy-rx (group image-keyword) (1+ space) (group image-name))
     (1 font-lock-keyword-face) (2 font-lock-variable-name-face)
     ;; Anchored match for attribute names.
     (,(renpy-rx (group image-name))
      (save-excursion
	(search-forward-regexp "=" (line-end-position) t))
      nil
      (0 font-lock-preprocessor-face)))
    (,(renpy-rx (or default-keyword define-keyword))
     (0 font-lock-keyword-face)
     ;; Anchored match for anything that looks like a valid name.
     (,(renpy-rx name)
      (save-excursion
	(search-forward-regexp "=" (line-end-position) t))
      nil
      (0 font-lock-variable-name-face)))
    (,(renpy-rx init-keyword)
     (0 font-lock-keyword-face)
     ;; Anchored match for what may follow an init keyword.
     (,(renpy-rx init-argument)
      (save-excursion
	(search-forward-regexp "=" (line-end-position) t))
      nil
      (0 font-lock-keyword-face)))
    ;; Properties passed to a scrollbar.
    (,(renpy-rx style-prefix-scrollbar
		(optional style-prefix)
		(or style-bar style-position transform-property))
     . font-lock-type-face)
    ;; Properties passed to a side.
    (,(renpy-rx style-prefix-side
		(optional style-prefix)
		(or style-position transform-property))
     . font-lock-type-face)
    ;; Properties passed to a text displayable.
    (,(renpy-rx style-prefix-text
		(optional style-prefix)
		(or style-position style-text transform-property))
     . font-lock-type-face)
    ;; Properties passed to a viewport.
    (,(renpy-rx style-prefix-viewport
		(optional style-prefix)
		(or style-position transform-property))
     . font-lock-type-face)
    ;; All style properties with optional prefix.
    (,(renpy-rx (optional style-prefix)
		(or style-position style-text style-window
		    style-button style-bar style-box style-grid
		    style-fixed style-margin transform-property))
     . font-lock-type-face)
    (,(renpy-rx keyword)	    . font-lock-keyword-face)
    (,(renpy-rx class-or-function)  . font-lock-builtin-face)
    (,(renpy-rx ui-statement)	    . font-lock-builtin-face)
    (,(renpy-rx transform-property) . font-lock-type-face)
    (,(renpy-rx warper)		    . font-lock-constant-face)))

(defconst renpy-syntax-propertize-function
  ;; Make outer chars of matching triple-quote sequences into generic
  ;; string delimiters.  Fixme: Is there a better way?
  ;; First avoid a sequence preceded by an odd number of backslashes.
  (syntax-propertize-rules
   (;; Backrefs don't work in syntax-propertize-rules!
    (concat "\\(?:\\([RUru]\\)[Rr]?\\|\\(?:\\=\\|[^\\]\\)\\(?:\\\\.\\)*\\)?" ;Prefix.
	    "\\(?:\\('\\)'\\('\\)\\|\\(?2:\"\\)\"\\(?3:\"\\)\\)")
    (3 (ignore (renpy-quote-syntax))))
   ;; This doesn't really help.
   ;;((rx (and ?\\ (group ?\n))) (1 " "))
   ))

(defun renpy-quote-syntax ()
  "Put `syntax-table' property correctly on triple quote.
Used for syntactic keywords.  N is the match number (1, 2 or 3)."
  ;; Given a triple quote, we have to check the context to know
  ;; whether this is an opening or closing triple or whether it's
  ;; quoted anyhow, and should be ignored.  (For that we need to do
  ;; the same job as `syntax-ppss' to be correct and it seems to be OK
  ;; to use it here despite initial worries.)  We also have to sort
  ;; out a possible prefix -- well, we don't _have_ to, but I think it
  ;; should be treated as part of the string.

  ;; Test cases:
  ;;  ur"""ar""" x='"' # """
  ;; x = ''' """ ' a
  ;; '''
  ;; x '"""' x """ \"""" x
  (save-excursion
    (goto-char (match-beginning 0))
    (let ((syntax (save-match-data (syntax-ppss))))
      (cond
       ((eq t (nth 3 syntax))           ; after unclosed fence
	;; Consider property for the last char if in a fenced string.
	(goto-char (nth 8 syntax))	; fence position
	(skip-chars-forward "uUrR")	; skip any prefix
	;; Is it a matching sequence?
	(if (eq (char-after) (char-after (match-beginning 2)))
	    (put-text-property (match-beginning 3) (match-end 3)
			       'syntax-table (string-to-syntax "|"))))
       ((match-end 1)
	;; Consider property for initial char, accounting for prefixes.
	(put-text-property (match-beginning 1) (match-end 1)
			   'syntax-table (string-to-syntax "|")))
       (t
	;; Consider property for initial char, accounting for prefixes.
	(put-text-property (match-beginning 2) (match-end 2)
			   'syntax-table (string-to-syntax "|")))))))

;; This isn't currently in `font-lock-defaults' as probably not worth
;; it -- we basically only mess with a few normally-symbol characters.

;; (defun renpy-font-lock-syntactic-face-function (state)
;;   "`font-lock-syntactic-face-function' for Renpy mode.
;; Returns the string or comment face as usual, with side effect of putting
;; a `syntax-table' property on the inside of the string or comment which is
;; the standard syntax table."
;;   (if (nth 3 state)
;;       (save-excursion
;; 	(goto-char (nth 8 state))
;; 	(condition-case nil
;; 	    (forward-sexp)
;; 	  (error nil))
;; 	(put-text-property (1+ (nth 8 state)) (1- (point))
;; 			   'syntax-table (standard-syntax-table))
;; 	'font-lock-string-face)
;;     (put-text-property (1+ (nth 8 state)) (line-end-position)
;; 			   'syntax-table (standard-syntax-table))
;;     'font-lock-comment-face))

;;;; Keymap and syntax

(defvar renpy-mode-map
  (let ((map (make-sparse-keymap)))
    ;; Mostly taken from renpy-mode.el.
    (define-key map ":" #'renpy-electric-colon)
    (define-key map "\177" #'renpy-backspace)
    (define-key map "\C-c<" #'renpy-shift-left)
    (define-key map "\C-c>" #'renpy-shift-right)
    (define-key map "\C-c\C-k" #'renpy-mark-block)
    (define-key map "\C-c\C-j" #'imenu)
    (define-key map "\C-c\C-n" #'renpy-next-statement)
    (define-key map "\C-c\C-p" #'renpy-previous-statement)
    (define-key map "\C-c\C-u" #'renpy-beginning-of-block)
    (easy-menu-define renpy-menu map "Ren'Py Mode menu"
      `("Ren'Py"
	:help "Ren'Py-specific Features"
	["Shift region left" renpy-shift-left :active mark-active
	 :help "Shift by a single indentation step"]
	["Shift region right" renpy-shift-right :active mark-active
	 :help "Shift by a single indentation step"]
	"-"
	["Mark block" renpy-mark-block
	 :help "Mark innermost block around point"]
	["Mark def/class" mark-defun
	 :help "Mark innermost definition around point"]
	"-"
	["Start of block" renpy-beginning-of-block
	 :help "Go to start of innermost definition around point"]
	["End of block" renpy-end-of-block
	 :help "Go to end of innermost definition around point"]
	["Start of def/class" beginning-of-defun
	 :help "Go to start of innermost definition around point"]
	["End of def/class" end-of-defun
	 :help "Go to end of innermost definition around point"]))
    map))

;; Fixme: add toolbar stuff for useful things like symbol help, send
;; region, at least.  (Shouldn't be specific to Renpy, obviously.)
;; eric has items including: (un)indent, (un)comment, restart script,
;; run script, debug script; also things for profiling, unit testing.

(defvar renpy-mode-syntax-table
  (let ((table (make-syntax-table)))
    ;; Give punctuation syntax to ASCII that normally has symbol
    ;; syntax or has word syntax and isn't a letter.
    (let ((symbol (string-to-syntax "_"))
	  (sst (standard-syntax-table)))
      (dotimes (i 128)
	(unless (= i ?_)
	  (if (equal symbol (aref sst i))
	      (modify-syntax-entry i "." table)))))
    (modify-syntax-entry ?$ "." table)
    (modify-syntax-entry ?% "." table)
    ;; exceptions
    (modify-syntax-entry ?# "<" table)
    (modify-syntax-entry ?\n ">" table)
    (modify-syntax-entry ?' "\"" table)
    (modify-syntax-entry ?` "$" table)
    table))

;;;; Utility stuff

(defsubst renpy-in-string-comment ()
  "Return non-nil if point is in a Renpy literal (a comment or string)."
  ;; We don't need to save the match data.
  (nth 8 (syntax-ppss)))

(defconst renpy-space-backslash-table
  (let ((table (copy-syntax-table renpy-mode-syntax-table)))
    (modify-syntax-entry ?\\ " " table)
    table)
  "`renpy-mode-syntax-table' with backslash given whitespace syntax.")

(defun renpy-skip-comments-blanks (&optional backward)
  "Skip comments and blank lines.
BACKWARD non-nil means go backwards, otherwise go forwards.
Backslash is treated as whitespace so that continued blank lines
are skipped.  Doesn't move out of comments -- should be outside
or at end of line."
  (let ((arg (if backward
		 ;; If we're in a comment (including on the trailing
		 ;; newline), forward-comment doesn't move backwards out
		 ;; of it.  Don't set the syntax table round this bit!
		 (let ((syntax (syntax-ppss)))
		   (if (nth 4 syntax)
		       (goto-char (nth 8 syntax)))
		   (- (point-max)))
	       (point-max))))
    (with-syntax-table renpy-space-backslash-table
      (forward-comment arg))))

(defun renpy-backslash-continuation-line-p ()
  "Non-nil if preceding line ends with backslash that is not in a comment."
  (and (eq ?\\ (char-before (line-end-position 0)))
       (not (syntax-ppss-context (syntax-ppss)))))

(defun renpy-continuation-line-p ()
  "Return non-nil if current line continues a previous one.
The criteria are that the previous line ends in a backslash outside
comments and strings, or that point is within brackets/parens."
  (or (renpy-backslash-continuation-line-p)
      (let ((depth (syntax-ppss-depth
		    (save-excursion ; syntax-ppss with arg changes point
		      (syntax-ppss (line-beginning-position))))))
	(or (> depth 0)
	    (if (< depth 0)	  ; Unbalanced brackets -- act locally
		(save-excursion
		  (condition-case ()
		      (progn (backward-up-list) t) ; actually within brackets
		    (error nil))))))))

(defun renpy-comment-line-p ()
  "Return non-nil if and only if current line has only a comment."
  (save-excursion
    (end-of-line)
    (when (eq 'comment (syntax-ppss-context (syntax-ppss)))
      (back-to-indentation)
      (looking-at (rx (or (syntax comment-start) line-end))))))

(defun renpy-blank-line-p ()
  "Return non-nil if and only if current line is blank."
  (save-excursion
    (beginning-of-line)
    (looking-at "\\s-*$")))

(defun renpy-beginning-of-string ()
  "Go to beginning of string around point.
Do nothing if not in string."
  (let ((state (syntax-ppss)))
    (when (eq 'string (syntax-ppss-context state))
      (goto-char (nth 8 state)))))

(defun renpy-open-block-statement-p (&optional bos)
  "Return non-nil if statement at point opens a block.
Any statement that ends in a colon opens a block.  BOS non-nil
means point is known to be at beginning of statement."
  (save-excursion
    (unless bos (renpy-beginning-of-statement))
    (and (< (point) (progn
		      (renpy-end-of-statement)
		      (renpy-skip-comments-blanks t)
		      (point)))
	 (eq ?: (char-before)))))

(defun renpy-close-block-statement-p (&optional bos)
  "Return non-nil if current line is a statement closing a block.
BOS non-nil means point is at beginning of statement.
The criteria are that the line isn't a comment or in string and
 starts with keyword `raise', `break', `continue' or `pass'."
  (save-excursion
    (unless bos (renpy-beginning-of-statement))
    (back-to-indentation)
    (looking-at (rx (or "return" "raise" "break" "continue" "pass")
		    symbol-end))))

(defun renpy-outdent-p ()
  "Return non-nil if current line should outdent a level."
  (save-excursion
    (back-to-indentation)
    (and (looking-at (rx (and (or "else" "finally" "except" "elif")
			      symbol-end)))
	 (not (renpy-in-string-comment))
	 ;; Ensure there's a previous statement and move to it.
	 (zerop (renpy-previous-statement))
	 (not (renpy-close-block-statement-p t))
	 ;; Fixme: check this
	 (not (renpy-open-block-statement-p)))))

;;;; Indentation.

(defcustom renpy-indent 4
  "Number of columns for a unit of indentation in Renpy mode.
See also `\\[renpy-guess-indent]'"
  :group 'renpy
  :type 'integer)
(put 'renpy-indent 'safe-local-variable 'integerp)

(defcustom renpy-guess-indent nil
  "Non-nil means Renpy mode guesses `renpy-indent' for the buffer."
  :type 'boolean
  :group 'renpy)

(defcustom renpy-indent-string-contents t
  "Non-nil means indent contents of multi-line strings together.
This means indent them the same as the preceding non-blank line.
Otherwise preserve their indentation.

This only applies to `doc' strings, i.e. those that form statements;
the indentation is preserved in others."
  :type '(choice (const :tag "Align with preceding" t)
		 (const :tag "Preserve indentation" nil))
  :group 'renpy)

(defcustom renpy-honour-comment-indentation nil
  "Non-nil means indent relative to preceding comment line.
Only do this for comments where the leading comment character is
followed by space.  This doesn't apply to comment lines, which
are always indented in lines with preceding comments."
  :type 'boolean
  :group 'renpy)

(defcustom renpy-continuation-offset 4
  "Number of columns of additional indentation for continuation lines.
Continuation lines follow a backslash-terminated line starting a
statement."
  :group 'renpy
  :type 'integer)

(defun renpy-guess-indent ()
  "Guess step for indentation of current buffer.
Set `renpy-indent' locally to the value guessed."
  (interactive)
  (save-excursion
    (save-restriction
      (widen)
      (goto-char (point-min))
      (let (done indent)
	(while (and (not done) (not (eobp)))
	  (when (and (re-search-forward (rx ?: (0+ space)
					    (or (syntax comment-start)
						line-end))
					nil 'move)
		     (renpy-open-block-statement-p))
	    (save-excursion
	      (renpy-beginning-of-statement)
	      (let ((initial (current-indentation)))
		(if (zerop (renpy-next-statement))
		    (setq indent (- (current-indentation) initial)))
		(if (and indent (>= indent 2) (<= indent 8)) ; sanity check
		    (setq done t))))))
	(when done
	  (when (/= indent (default-value 'renpy-indent))
	    (setq-local renpy-indent indent)
	    (unless (= tab-width renpy-indent)
	      (setq indent-tabs-mode nil)))
	  indent)))))

;; Alist of possible indentations and start of statement they would
;; close.  Used in indentation cycling (below).
(defvar renpy-indent-list nil
  "Internal use.")
;; Length of the above
(defvar renpy-indent-list-length nil
  "Internal use.")
;; Current index into the alist.
(defvar renpy-indent-index nil
  "Internal use.")

(defun renpy-calculate-indentation ()
  "Calculate Renpy indentation for line at point."
  (setq renpy-indent-list nil
	renpy-indent-list-length 1)
  (save-excursion
    (beginning-of-line)
    (let ((syntax (syntax-ppss))
	  start)
      (cond
       ((eq 'string (syntax-ppss-context syntax)) ; multi-line string
	(cond
	 ;; Indentation for Ren'Py dialogue strings, which are allowed to
	 ;; span multiple lines.
	 ;; FIXME: Should this be a user preference?
	 ((renpy-in-script-statement-p)
	  (goto-char (nth 8 syntax))
	  (+ (current-column) (if (eq (skip-syntax-forward "|\"") 1)
				  ;; Align with the inside of a single quote.
				  1
				;; No adjustment for a triple quote.
				;; FIXME: Should this be a user preference?
				0)))
	 ((not renpy-indent-string-contents)
	  (current-indentation))
	 ;; Only respect `renpy-indent-string-contents' in doc
	 ;; strings (defined as those which form statements).
	 ((not (save-excursion
		 (renpy-beginning-of-statement)
		 (looking-at (rx (or (syntax string-delimiter)
				     (syntax string-quote))))))
	  (current-indentation))
	 (t
	  ;; Find indentation of preceding non-blank line within string.
	  (setq start (nth 8 syntax))
	  (forward-line -1)
	  (while (and (< start (point)) (looking-at "\\s-*$"))
	    (forward-line -1))
	  (current-indentation))))
       ((renpy-continuation-line-p)   ; after backslash, or bracketed
	(let ((point (point))
	      (open-start (cadr syntax))
	      (backslash (renpy-backslash-continuation-line-p))
	      (colon (eq ?: (char-before (1- (line-beginning-position))))))
	  (if open-start
	      ;; Inside bracketed expression.
	      (progn
		(goto-char (1+ open-start))
		;; Look for first item in list (preceding point) and
		;; align with it, if found.
		(if (with-syntax-table renpy-space-backslash-table
		      (let ((parse-sexp-ignore-comments t))
			(condition-case ()
			    (progn (forward-sexp)
				   (backward-sexp)
				   (< (point) point))
			  (error nil))))
		    ;; Extra level if we're backslash-continued or
		    ;; following a key.
		    (if (or backslash colon)
			(+ renpy-indent (current-column))
			(current-column))
		  ;; Otherwise indent relative to statement start, one
		  ;; level per bracketing level.
		  (goto-char (1+ open-start))
		  (renpy-beginning-of-statement)
		  (+ (current-indentation) (* (car syntax) renpy-indent))))
	    ;; Otherwise backslash-continued.
	    (forward-line -1)
	    (if (renpy-continuation-line-p)
		;; We're past first continuation line.  Align with
		;; previous line.
		(current-indentation)
	      ;; First continuation line.  Indent one step, with an
	      ;; extra one if statement opens a block.
	      (renpy-beginning-of-statement)
	      (+ (current-indentation) renpy-continuation-offset
		 (if (renpy-open-block-statement-p t)
		     renpy-indent
		   0))))))
       ((bobp) 0)
       ;; Fixme: Like renpy-mode.el; not convinced by this.
       ((looking-at (rx (0+ space) (syntax comment-start)
			(not (any " \t\n")))) ; non-indentable comment
	(current-indentation))
       ((and renpy-honour-comment-indentation
	     ;; Back over whitespace, newlines, non-indentable comments.
	     (catch 'done
	       (while (cond ((bobp) nil)
			    ((not (forward-comment -1))
			     nil)	; not at comment start
			    ;; Now at start of comment -- trailing one?
			    ((/= (current-column) (current-indentation))
			     nil)
			    ;; Indentable comment, like renpy-mode.el?
			    ((and (looking-at (rx (syntax comment-start)
						  (or space line-end)))
				  (/= 0 (current-column)))
			     (throw 'done (current-column)))
			    ;; Else skip it (loop).
			    (t))))))
       (t
	(renpy-indentation-levels)
	;; Prefer to indent comments with an immediately-following
	;; statement, e.g.
	;;       ...
	;;   # ...
	;;   def ...
	(when (and (> renpy-indent-list-length 1)
		   (renpy-comment-line-p))
	  (forward-line)
	  (unless (renpy-comment-line-p)
	    (let ((elt (assq (current-indentation) renpy-indent-list)))
	      (setq renpy-indent-list
		    (nconc (delete elt renpy-indent-list)
			   (list elt))))))
	(caar (last renpy-indent-list)))))))

;; Cycling through the possible indentations with successive TABs.

;; These don't need to be buffer-local since they're only relevant
;; during a cycle.

(defun renpy-initial-text ()
  "Text of line following indentation and ignoring any trailing comment."
  (save-excursion
    (buffer-substring (progn
			(back-to-indentation)
			(point))
		      (max (point)
			   (progn
			     (end-of-line)
			     (renpy-skip-comments-blanks t)
			     (point))))))

(defconst renpy-block-pairs
  '(("else" "if" "showif" "elif" "while" "for" "try" "except")
    ("elif" "if" "showif" "elif")
    ("except" "try" "except")
    ("finally" "else" "try" "except"))
  "Alist of keyword matches.
The car of an element is a keyword introducing a statement which
can close a block opened by a keyword in the cdr.")

(defun renpy-first-word ()
  "Return first word (actually symbol) on the line."
  (save-excursion
    (back-to-indentation)
    (current-word t)))

(defun renpy-indentation-levels ()
  "Return a list of possible indentations for this line.
It is assumed not to be a continuation line or in a multi-line string.
Includes the default indentation and those which would close all
enclosing blocks.  Elements of the list are actually pairs:
\(INDENTATION . TEXT), where TEXT is the initial text of the
corresponding block opening (or nil)."
  (save-excursion
    (let ((initial "")
	  levels indent)
      ;; Only one possibility immediately following a block open
      ;; statement, assuming it doesn't have a `suite' on the same line.
      (cond
       ((save-excursion (and (renpy-previous-statement)
			     (renpy-open-block-statement-p t)
			     (setq indent (current-indentation))
			     ;; Check we don't have something like:
			     ;;   if ...: ...
			     (if (progn (renpy-end-of-statement)
					(renpy-skip-comments-blanks t)
					(eq ?: (char-before)))
				 (setq indent (+ renpy-indent indent)))))
	(push (cons indent initial) levels))
       ;; Only one possibility for comment line immediately following
       ;; another.
       ((save-excursion
	  (when (renpy-comment-line-p)
	    (forward-line -1)
	    (if (renpy-comment-line-p)
		(push (cons (current-indentation) initial) levels)))))
       ;; Fixme: Maybe have a case here which indents (only) first
       ;; line after a lambda.
       (t
	(let ((start (car (assoc (renpy-first-word) renpy-block-pairs))))
	  (renpy-previous-statement)
	  ;; Is this a valid indentation for the line of interest?
	  (unless (or (if start		; potentially only outdentable
			  ;; Check for things like:
			  ;;   if ...: ...
			  ;;   else ...:
			  ;; where the second line need not be outdented.
			  (not (member (renpy-first-word)
				       (cdr (assoc start
						   renpy-block-pairs)))))
		      ;; Not sensible to indent to the same level as
		      ;; previous `return' &c.
		      (renpy-close-block-statement-p))
	    (push (cons (current-indentation) (renpy-initial-text))
		  levels))
	  (while (renpy-beginning-of-block)
	    (when (or (not start)
		      (member (renpy-first-word)
			      (cdr (assoc start renpy-block-pairs))))
	      (push (cons (current-indentation) (renpy-initial-text))
		    levels))))))
      (prog1 (or levels (setq levels '((0 . ""))))
	(setq renpy-indent-list levels
	      renpy-indent-list-length (length renpy-indent-list))))))

;; This is basically what `renpy-indent-line' would be if we didn't
;; do the cycling.
(defun renpy-indent-line-1 (&optional leave)
  "Subroutine of `renpy-indent-line'.
Does non-repeated indentation.  LEAVE non-nil means leave
indentation if it is valid, i.e. one of the positions returned by
`renpy-calculate-indentation'."
  (let ((target (renpy-calculate-indentation))
	(pos (- (point-max) (point))))
    (if (or (= target (current-indentation))
	    ;; Maybe keep a valid indentation.
	    (and leave renpy-indent-list
		 (assq (current-indentation) renpy-indent-list)))
	(if (< (current-column) (current-indentation))
	    (back-to-indentation))
      (beginning-of-line)
      (delete-horizontal-space)
      (indent-to target)
      (if (> (- (point-max) pos) (point))
	  (goto-char (- (point-max) pos))))))

(defun renpy-indent-line ()
  "Indent current line as Renpy code.
When invoked via `indent-for-tab-command', cycle through possible
indentations for current line.  The cycle is broken by a command
different from `indent-for-tab-command', i.e. successive TABs do
the cycling."
  (interactive)
  (if (and (eq this-command 'indent-for-tab-command)
	   (eq last-command this-command))
      (if (= 1 renpy-indent-list-length)
	  (message "Sole indentation")
	(progn (setq renpy-indent-index
		     (% (1+ renpy-indent-index) renpy-indent-list-length))
	       (beginning-of-line)
	       (delete-horizontal-space)
	       (indent-to (car (nth renpy-indent-index renpy-indent-list)))
	       (if (renpy-block-end-p)
		   (let ((text (cdr (nth renpy-indent-index
					 renpy-indent-list))))
		     (if text
			 (message "Closes: %s" text))))))
    (renpy-indent-line-1)
    (setq renpy-indent-index (1- renpy-indent-list-length))))

(defun renpy-indent-region (start end)
  "`indent-region-function' for Renpy.
START and END specify the region to indent.  Validly-indented
lines are left alone, i.e. they are not indented to another valid
position."
  (save-excursion
    (goto-char end)
    (setq end (point-marker))
    (goto-char start)
    (or (bolp) (forward-line 1))
    (while (< (point) end)
      (or (and (bolp) (eolp))
	  (renpy-indent-line-1 t))
      (forward-line 1))
    (move-marker end nil)))

(defun renpy-block-end-p ()
  "Return a non-nil when the current line closes a block.
A block can be clsoed by a statement closing a block, or by a
blank line indented to where it would close a block."
  (and (not (renpy-comment-line-p))
       (or (renpy-close-block-statement-p t)
	   (< (current-indentation)
	      (save-excursion
		(renpy-previous-statement)
		(current-indentation))))))

;;;; Movement.

;; Fixme:  Define {for,back}ward-sexp-function?  Maybe skip units like
;; block, statement, depending on context.

(defun renpy-beginning-of-defun ()
  "`beginning-of-defun-function' for Renpy.
Finds beginning of innermost nested class or method definition.
Returns the name of the definition found at the end, or nil if
reached start of buffer."
  (let ((ci (current-indentation))
	(def-re (rx line-start (0+ space) (or "def" "class") (1+ space)
		    (group (1+ (or word (syntax symbol))))))
	found lep) ;; def-line
    (if (renpy-comment-line-p)
	(setq ci most-positive-fixnum))
    (while (and (not (bobp)) (not found))
      ;; Treat bol at beginning of function as outside function so
      ;; that successive C-M-a makes progress backwards.
      ;;(setq def-line (looking-at def-re))
      (unless (bolp) (end-of-line))
      (setq lep (line-end-position))
      (if (and (re-search-backward def-re nil 'move)
	       ;; Must be less indented or matching top level, or
	       ;; equally indented if we started on a definition line.
	       (let ((in (current-indentation)))
		 (or (and (zerop ci) (zerop in))
		     (= lep (line-end-position)) ; on initial line
		     ;; Not sure why it was like this -- fails in case of
		     ;; last internal function followed by first
		     ;; non-def statement of the main body.
;; 		     (and def-line (= in ci))
		     (= in ci)
		     (< in ci)))
	       (not (renpy-in-string-comment)))
	  (setq found t)))
    found))

(defun renpy-end-of-defun ()
  "`end-of-defun-function' for Renpy.
Finds end of innermost nested class or method definition."
  (let ((orig (point))
	(pattern (rx line-start (0+ space) (or "def" "class") space)))
    ;; Go to start of current block and check whether it's at top
    ;; level.  If it is, and not a block start, look forward for
    ;; definition statement.
    (when (renpy-comment-line-p)
      (end-of-line)
      (forward-comment most-positive-fixnum))
    (if (not (renpy-open-block-statement-p))
	(renpy-beginning-of-block))
    (if (zerop (current-indentation))
	(unless (renpy-open-block-statement-p)
	  (while (and (re-search-forward pattern nil 'move)
		      (renpy-in-string-comment))) ; just loop
	  (unless (eobp)
	    (beginning-of-line)))
      ;; Don't move before top-level statement that would end defun.
      (end-of-line)
      (renpy-beginning-of-defun))
    ;; If we got to the start of buffer, look forward for
    ;; definition statement.
    (if (and (bobp) (not (looking-at "def\\|class")))
	(while (and (not (eobp))
		    (re-search-forward pattern nil 'move)
		    (renpy-in-string-comment)))) ; just loop
    ;; We're at a definition statement (or end-of-buffer).
    (unless (eobp)
      (renpy-end-of-block)
      ;; Count trailing space in defun (but not trailing comments).
      (skip-syntax-forward " >")
      (unless (eobp)			; e.g. missing final newline
	(beginning-of-line)))
    ;; Catch pathological cases like this, where the beginning-of-defun
    ;; skips to a definition we're not in:
    ;; if ...:
    ;;     ...
    ;; else:
    ;;     ...  # point here
    ;;     ...
    ;;     def ...
    (if (< (point) orig)
	(goto-char (point-max)))))

(defun renpy-beginning-of-statement ()
  "Go to the start of current statement and return point.
Accounts for continuation lines, multi-line strings, and
multi-line bracketed expressions."
  (while
      (if (renpy-backslash-continuation-line-p)
	  (progn (forward-line -1) t)
	(beginning-of-line)
	(or (renpy-beginning-of-string)
	    (renpy-skip-out))))
  (back-to-indentation)
  (point))

(defun renpy-skip-out (&optional forward syntax)
  "Skip out of any nested brackets.
Skip forward if FORWARD is non-nil, else backward.
If SYNTAX is non-nil it is the state returned by `syntax-ppss' at point.
Return non-nil if and only if skipping was done."
  ;; FIXME: Use syntax-ppss-toplevel-pos.
  (let ((depth (syntax-ppss-depth (or syntax (syntax-ppss))))
	(forward (if forward -1 1)))
    (unless (zerop depth)
      (if (> depth 0)
	  ;; Skip forward out of nested brackets.
	  (condition-case ()		; beware invalid syntax
	      (progn (backward-up-list (* forward depth)) t)
	    (error nil))
	;; Invalid syntax (too many closed brackets).
	;; Skip out of as many as possible.
	(let (done)
	  (while (condition-case ()
		     (progn (backward-up-list forward)
			    (setq done t))
		   (error nil)))
	  done)))))

(defun renpy-end-of-statement ()
  "Go to the end of the current statement and return point.
Usually this is the start of the next line, but if this is a
multi-line statement we need to skip over the continuation lines.
On a comment line, go to end of line."
  (end-of-line)
  (while (let (comment)
	   ;; Move past any enclosing strings and sexps, or stop if
	   ;; we're in a comment.
	   (while (let ((s (syntax-ppss)))
		    (cond ((eq 'comment (syntax-ppss-context s))
			   (setq comment t)
			   nil)
			  ((eq 'string (syntax-ppss-context s))
			   ;; Go to start of string and skip it.
			   (let ((pos (point)))
			     (goto-char (nth 8 s))
			     (condition-case () ; beware invalid syntax
				 (progn (forward-sexp) t)
			       ;; If there's a mismatched string, make sure
			       ;; we still overall move *forward*.
			       (error (goto-char pos) (end-of-line)))))
			  ((renpy-skip-out t s))))
	     (end-of-line))
	   (and (not comment)
		(not (eobp))
		(eq ?\\ (char-before)))) ; Line continued?
    (end-of-line 2))			 ; Try next line.
  (point))

(defun renpy-previous-statement (&optional count)
  "Go to start of previous statement.
With argument COUNT, do it COUNT times.  Stop at beginning of buffer.
Return count of statements left to move."
  (interactive "p")
  (unless count (setq count 1))
  (if (< count 0)
      (renpy-next-statement (- count))
    (renpy-beginning-of-statement)
    (while (and (> count 0) (not (bobp)))
      (renpy-skip-comments-blanks t)
      (renpy-beginning-of-statement)
      (unless (bobp) (setq count (1- count))))
    count))

(defun renpy-next-statement (&optional count)
  "Go to start of next statement.
With argument COUNT, do it COUNT times.  Stop at end of buffer.
Return count of statements left to move."
  (interactive "p")
  (unless count (setq count 1))
  (if (< count 0)
      (renpy-previous-statement (- count))
    (beginning-of-line)
    (let (bogus)
      (while (and (> count 0) (not (eobp)) (not bogus))
	(renpy-end-of-statement)
	(renpy-skip-comments-blanks)
	(if (eq 'string (syntax-ppss-context (syntax-ppss)))
	    (setq bogus t)
	  (unless (eobp)
	    (setq count (1- count))))))
    count))

(defun renpy-beginning-of-block (&optional arg)
  "Go to start of current block.
With numeric arg, do it that many times.  If ARG is negative, call
`renpy-end-of-block' instead.
If point is on the first line of a block, use its outer block.
If current statement is in column zero, don't move and return nil.
Otherwise return non-nil."
  (interactive "p")
  (unless arg (setq arg 1))
  (cond
   ((zerop arg))
   ((< arg 0) (renpy-end-of-block (- arg)))
   (t
    (let ((point (point)))
      (if (or (renpy-comment-line-p)
	      (renpy-blank-line-p))
	  (renpy-skip-comments-blanks t))
      (renpy-beginning-of-statement)
      (let ((ci (current-indentation)))
	(if (zerop ci)
	    (not (goto-char point))	; return nil
	  ;; Look upwards for less indented statement.
	  (if (catch 'done
;; This is slower than the below.
;; 	  (while (zerop (renpy-previous-statement))
;; 	    (when (and (< (current-indentation) ci)
;; 		       (renpy-open-block-statement-p t))
;; 	      (beginning-of-line)
;; 	      (throw 'done t)))
		(while (and (zerop (forward-line -1)))
		  (when (and (< (current-indentation) ci)
			     (not (renpy-comment-line-p))
			     ;; Move to beginning to save effort in case
			     ;; this is in string.
			     (progn (renpy-beginning-of-statement) t)
			     (renpy-open-block-statement-p t))
		    (beginning-of-line)
		    (throw 'done t)))
		(not (goto-char point))) ; Failed -- return nil
	      (renpy-beginning-of-block (1- arg)))))))))

(defun renpy-end-of-block (&optional arg)
  "Go to end of current block.
With numeric arg, do it that many times.  If ARG is negative,
call `renpy-beginning-of-block' instead.
If current statement is in column zero and doesn't open a block,
don't move and return nil.  Otherwise return t."
  (interactive "p")
  (unless arg (setq arg 1))
  (if (< arg 0)
      (renpy-beginning-of-block (- arg))
    (while (and (> arg 0)
		(let* ((point (point))
		       (_ (if (renpy-comment-line-p)
			      (renpy-skip-comments-blanks t)))
		       (ci (current-indentation))
		       (open (renpy-open-block-statement-p)))
		  (if (and (zerop ci) (not open))
		      (not (goto-char point))
		    (catch 'done
		      (while (zerop (renpy-next-statement))
			(when (or (and open (<= (current-indentation) ci))
				  (< (current-indentation) ci))
			  (renpy-skip-comments-blanks t)
			  (beginning-of-line 2)
			  (throw 'done t)))))))
      (setq arg (1- arg)))
    (zerop arg)))

(defun renpy-in-script-statement-p ()
  "Return a non-nil value when point is within the main game script."
  (save-excursion
    (or (null (renpy-beginning-of-block))
	(looking-at-p (renpy-rx label-keyword)))))

(defvar renpy-which-func-length-limit 40
  "Non-strict length limit for `renpy-which-func' output.")

(defun renpy-which-func ()
  "Return the name of the function which surrounds point."
  (let ((function-name (renpy-current-defun renpy-which-func-length-limit)))
    (set-text-properties 0 (length function-name) nil function-name)
    function-name))

;;;; Imenu.

(defvar renpy-generic-imenu
  `((nil ,(renpy-rx label-keyword (1+ space) (group label-name)) 1)
    ("/class" ,(renpy-rx symbol-start "class" (1+ space) (group name)) 1)
    ("/function" ,(renpy-rx symbol-start "def" (1+ space) (group name)) 1)
    ("/image" ,(renpy-rx image-keyword (1+ space) (group name)) 1)
    ("/screen" ,(renpy-rx screen-keyword (1+ space) (group name)) 1)
    ("/style" ,(renpy-rx style-keyword (1+ space) (group name)) 1)
    ("/transform" ,(renpy-rx transform-keyword (1+ space) (group name)) 1)
    ("/define" ,(renpy-rx define-keyword (1+ space) (group name)) 1)
    ("/default" ,(renpy-rx default-keyword (1+ space) (group name)) 1)))

;;;; `Electric' commands.

(defun renpy-electric-colon (arg)
  "Insert a colon and maybe outdent the line if it is a statement like `else'.
With numeric ARG, just insert that many colons.  With \\[universal-argument],
just insert a single colon."
  (interactive "*P")
  (self-insert-command (if (not (integerp arg)) 1 arg))
  (and (not arg)
       (eolp)
       (renpy-outdent-p)
       (not (renpy-in-string-comment))
       (> (current-indentation) (renpy-calculate-indentation))
       (renpy-indent-line)))		; OK, do it
(put 'renpy-electric-colon 'delete-selection t)

(defun renpy-backspace (arg)
  "Maybe delete a level of indentation on the current line.
Do so if point is at the end of the line's indentation outside
strings and comments.
Otherwise just call `backward-delete-char-untabify'.
Repeat ARG times."
  (interactive "*p")
  (if (or (/= (current-indentation) (current-column))
	  (bolp)
	  (renpy-continuation-line-p)
	  (renpy-in-string-comment))
      (backward-delete-char-untabify arg)
    ;; Look for the largest valid indentation which is smaller than
    ;; the current indentation.
    (let ((indent 0)
	  (ci (current-indentation))
	  (indents (renpy-indentation-levels))
	  initial)
      (dolist (x indents)
	(if (< (car x) ci)
	    (setq indent (max indent (car x)))))
      (setq initial (cdr (assq indent indents)))
      (if (> (length initial) 0)
	  (message "Closes %s" initial))
      (delete-horizontal-space)
      (indent-to indent))))
(put 'renpy-backspace 'delete-selection 'supersede)

(defun renpy-fill-paragraph (&optional justify)
  "`fill-paragraph-function' handling multi-line strings and possibly comments.

For Ren'Py dialogue, if point is within a string, fill the string
with a prefix which aligns with the string indentation position.

Otherwise, if any of the current line is in or at the end of a
multi-line string, fill the string or the paragraph of it that
point is in, preserving the string's indentation.

If JUSTIFY is non-nil, justify as well."
  (interactive "P")
  (cond
   ((fill-comment-paragraph justify))
   ;; Ren'Py dialogue.
   ((and (renpy-in-script-statement-p)
	 (let ((syntax (syntax-ppss)))
	   (when (nth 3 syntax)
	     (save-excursion
	       (goto-char (nth 8 syntax))
	       ;; Check this is a single quoted string.	 For triple-quoted
	       ;; strings the python docstring filling should be fine.
	       (when (eq (skip-syntax-forward "|\"") 1)
		 (let ((fill-prefix (make-string (current-column) ?\s))
		       fill-paragraph-function)
		   (fill-paragraph justify))))))))
   ;; Original Python.
   (t
    (save-excursion
      (end-of-line)
      (let* ((syntax (syntax-ppss))
	     (orig (point))
	     start end)
	(cond ((nth 4 syntax)	; comment.   fixme: loses with trailing one
	       (let (fill-paragraph-function)
		 (fill-paragraph justify)))
	      ;; The `paragraph-start' and `paragraph-separate'
	      ;; variables don't allow us to delimit the last
	      ;; paragraph in a multi-line string properly, so narrow
	      ;; to the string and then fill around (the end of) the
	      ;; current line.
	      ((nth 3 syntax)	; in fenced string
	       (goto-char (nth 8 syntax)) ; string start
	       (setq start (line-beginning-position))
	       (setq end (condition-case () ; for unbalanced quotes
			     (progn (forward-sexp)
				    (- (point) 3))
			   (error (point-max)))))
	      ((re-search-backward "\\s|\\s-*\\=" nil t) ; end of fenced string
	       (forward-char)
	       (setq end (point))
	       (condition-case ()
		   (progn (backward-sexp)
			  (setq start (line-beginning-position)))
		 (error nil))))
	(when end
	  (save-restriction
	    (narrow-to-region start end)
	    (goto-char orig)
	    ;; Avoid losing leading and trailing newlines in doc
	    ;; strings written like:
	    ;;   """
	    ;;   ...
	    ;;   """
	    (let ((paragraph-separate
		   ;; Note that the string could be part of an
		   ;; expression, so it can have preceding and
		   ;; trailing non-whitespace.
		   (concat
		    (rx (or
			 ;; Opening triple quote without following text.
			 (and (* nonl)
			      (group (syntax string-delimiter))
			      (repeat 2 (backref 1))
			      ;; Fixme:  Not sure about including
			      ;; trailing whitespace.
			      (* (any " \t"))
			      eol)
			 ;; Closing trailing quote without preceding text.
			 (and (group (any ?\" ?')) (backref 2)
			      (syntax string-delimiter))))
		    "\\(?:" paragraph-separate "\\)"))
		  fill-paragraph-function)
	      (fill-paragraph justify)))))))))

(defun renpy-shift-left (start end &optional count)
  "Shift lines in region COUNT (the prefix arg) columns to the left.
COUNT defaults to `renpy-indent'.  If region isn't active, just shift
current line.  The region shifted includes the lines in which START and
END lie.  It is an error if any lines in the region are indented less than
COUNT columns."
  (interactive
   (if mark-active
       (list (region-beginning) (region-end) current-prefix-arg)
     (list (line-beginning-position) (line-end-position) current-prefix-arg)))
  (if count
      (setq count (prefix-numeric-value count))
    (setq count renpy-indent))
  (when (> count 0)
    (save-excursion
      (goto-char start)
      (while (< (point) end)
	(if (and (< (current-indentation) count)
		 (not (looking-at "[ \t]*$")))
	    (error "Can't shift all lines enough"))
	(forward-line))
      (indent-rigidly start end (- count)))))

(add-to-list 'debug-ignored-errors "^Can't shift all lines enough")

(defun renpy-shift-right (start end &optional count)
  "Shift lines in region COUNT (the prefix arg) columns to the right.
COUNT defaults to `renpy-indent'.  If region isn't active, just shift
current line.  The region shifted includes the lines in which START and
END lie."
  (interactive
   (if mark-active
       (list (region-beginning) (region-end) current-prefix-arg)
     (list (line-beginning-position) (line-end-position) current-prefix-arg)))
  (if count
      (setq count (prefix-numeric-value count))
    (setq count renpy-indent))
  (indent-rigidly start end count))

(defun renpy-outline-level ()
  "Return the `outline-mode' level.
The level is the number of `renpy-indent' steps of indentation
of current statement."
  (save-excursion
    (renpy-beginning-of-statement)
    (1+ (/ (current-indentation) renpy-indent))))

;; Fixme: Consider top-level assignments, imports, &c.
(defun renpy-current-defun (&optional length-limit)
  "Return the name of the current function.
Ignore names which are longer than LENGTH-LIMIT."
  (save-excursion
    ;; Move up the tree of nested `class' and `def' blocks until we
    ;; get to zero indentation, accumulating the defined names.
    (let ((accum)
	  (length -1))
      (catch 'done
	(while (or (null length-limit)
		   (null (cdr accum))
		   (< length length-limit))
	  (let ((started-from (point)))
	    (renpy-beginning-of-block)
	    (end-of-line)
	    (beginning-of-defun)
	    (when (= (point) started-from)
	      (throw 'done nil)))
	  (when (looking-at (rx (0+ space) (or "def" "class") (1+ space)
				(group (1+ (or word (syntax symbol))))))
	    (push (match-string 1) accum)
	    (setq length (+ length 1 (length (car accum)))))
	  (when (= (current-indentation) 0)
	    (throw 'done nil))))
      (when accum
	(when (and length-limit (> length length-limit))
	  (setcar accum ".."))
	(mapconcat 'identity accum ".")))))

(defun renpy-mark-block ()
  "Mark the block around point.
Uses `renpy-beginning-of-block', `renpy-end-of-block'."
  (interactive)
  (push-mark)
  (renpy-beginning-of-block)
  (push-mark (point) nil t)
  (renpy-end-of-block)
  (exchange-point-and-mark))

;;;; Completion

(defcustom renpy-setup-completion t
  "Non-nil means Renpy mode sets up completion for the buffer."
  :type 'boolean
  :group 'renpy)

(defun renpy--completion-context ()
  "Return the completion category for point."
  ;; TODO: Make sure the point is not within a comment or a string.
  ;; TODO: More specific contexts: show text, show expression, ...
  (save-excursion
    (skip-syntax-backward "w_")
    (let* ((_ (skip-syntax-backward " "))
           (prev  (thing-at-point 'symbol)))
      (cond
       ;; call <point>
       ((equal prev "call") :label)
       ;; jump <point>
       ((equal prev "jump") :label)
       ;; show/scene/hide <point>
       ((member prev '("show" "scene" "hide")) :image)
       ;; at <point>
       ((equal prev "at") :transform)
       ;; default
       (t :none)))))

(defvar renpy--label-definition-re
  (renpy-rx label-keyword (1+ space) (group label-name))
  "Regexp for looking up label definitions.")

(defun renpy--collect-labels ()
  "Return all unique label names in the current buffer."
  (let (labels)
    (save-excursion
      (goto-char (point-min))
      (while (re-search-forward renpy--label-definition-re nil t)
        (push (match-string-no-properties 1) labels)))
    labels))

(defvar renpy--image-definition-re
  (renpy-rx image-keyword (1+ space)
	    (group image-name		; tag
		   (0+ space name))	; attributes
	    (0+ space) "=")
  "Regexp for looking up image definitions.")

(defun renpy--collect-images ()
  "Return all unique image names in the current buffer."
  (let (images)
    (save-excursion
      (goto-char (point-min))
      (while (re-search-forward renpy--image-definition-re nil t)
        (push (match-string-no-properties 1) images)))
    images))

;;;###autoload
(defun renpy-completion-at-point ()
  "Provide completion data for the symbol at point in Ren'Py buffers."
  (when (derived-mode-p 'renpy-mode)
    (let (candidates beg end)
      (pcase (renpy--completion-context)
	(:label
	 (setq end (point)
	       beg (save-excursion
		     (skip-syntax-backward "w_")
		     (point))
	       candidates (renpy--collect-labels)))
	(:image
	 (setq end (point)
	       beg (save-excursion
		     (skip-syntax-backward "w_")
		     (point))
	       candidates (renpy--collect-images)))
	(_ nil))
      (when candidates
        (list beg end candidates :exclusive 'no)))))

;;;###autoload
(defun renpy-enable-completion-at-point ()
  "Enable Ren'Py completion in the current buffer."
  (add-hook 'completion-at-point-functions
            #'renpy-completion-at-point nil t))

;;;; Modes.

;;;###autoload
(define-derived-mode renpy-mode prog-mode "Ren'Py"
  "Major mode for editing Renpy files.
Turns on Font Lock mode unconditionally since it is currently required
for correct parsing of the source.
See also `jython-mode', which is actually invoked if the buffer appears to
contain Jython code.  See also `run-renpy' and associated Renpy mode
commands for running Renpy under Emacs.

The Emacs commands which work with `defun's, e.g. \\[beginning-of-defun], deal
with nested `def' and `class' blocks.  They take the innermost one as
current without distinguishing method and class definitions.  Used multiple
times, they move over others at the same indentation level until they reach
the end of definitions at that level, when they move up a level.
\\<renpy-mode-map>
Colon is electric: it outdents the line if appropriate, e.g. for
an else statement.  \\[renpy-backspace] at the beginning of an indented statement
deletes a level of indentation to close the current block; otherwise it
deletes a character backward.  TAB indents the current line relative to
the preceding code.  Successive TABs, with no intervening command, cycle
through the possibilities for indentation on the basis of enclosing blocks.

\\[fill-paragraph] fills comments and multi-line strings appropriately, but has no
effect outside them.

Supports Eldoc mode (only for functions, using a Renpy process),
Info-Look and Imenu.  In Outline minor mode, `class' and `def'
lines count as headers.  Symbol completion is available in the
same way as in the Renpy shell using the `rlcompleter' module
and this is added to the Hippie Expand functions locally if
Hippie Expand mode is turned on.  Completion of symbols of the
form x.y only works if the components are literal
module/attribute names, not variables.  An abbrev table is set up
with skeleton expansions for compound statement templates.

\\{renpy-mode-map}"
  :group 'renpy
  (setq-local font-lock-defaults
	      '(renpy-font-lock-keywords
		nil nil nil nil
		;; This probably isn't worth it.
		;; (font-lock-syntactic-face-function
		;;  . renpy-font-lock-syntactic-face-function)
		))
  (setq-local syntax-propertize-function renpy-syntax-propertize-function)
  (setq-local parse-sexp-lookup-properties t)
  (setq-local parse-sexp-ignore-comments t)
  (setq-local comment-start "#")
  (setq-local indent-line-function #'renpy-indent-line)
  (setq-local indent-region-function #'renpy-indent-region)
  (setq-local paragraph-start "\\s-*$")
  (setq-local fill-paragraph-function #'renpy-fill-paragraph)
  (setq-local require-final-newline mode-require-final-newline)
  (setq-local add-log-current-defun-function #'renpy-current-defun)
  (setq-local outline-regexp
	      (rx (1+ not-newline) ?: (0+ space) (or (syntax <) eol)))
  (setq-local outline-level #'renpy-outline-level)
  (setq-local open-paren-in-column-0-is-defun-start nil)
  (setq-local beginning-of-defun-function #'renpy-beginning-of-defun)
  (setq-local end-of-defun-function #'renpy-end-of-defun)
  (add-hook 'which-func-functions 'renpy-which-func nil t)

  (setq imenu-create-index-function #'imenu-default-create-index-function)
  (setq imenu-generic-expression renpy-generic-imenu)

  ;; Inhibit `electric-indent-mode'.
  (setq electric-indent-inhibit t)
  ;; Setup indentation (Ren'Py cannot use tabs).
  (when renpy-guess-indent (renpy-guess-indent))
  (setq indent-tabs-mode nil)

  ;; Install the capf function.
  (when renpy-setup-completion
    (renpy-enable-completion-at-point)))

;; Not done automatically in Emacs 21 or 22.
(defcustom renpy-mode-hook nil
  "Hook run when entering Renpy mode."
  :group 'renpy
  :type 'hook)
(custom-add-option 'renpy-mode-hook 'imenu-add-menubar-index)
(custom-add-option 'renpy-mode-hook 'abbrev-mode)

(provide 'renpy)

;;; renpy.el ends here
