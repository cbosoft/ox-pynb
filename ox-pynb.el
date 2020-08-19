;;; ox-pynb.el --- Summary
;;;
;;; Export an org mode document to a Jupyter Notebook - blocks of text and
;;; non-python source are exported to markdown blocks, while python source is
;;; exported to python blocks in the notebook.
;;; 
;;; Commentary:
;;;

;;; Code:
(require 'ox-html)

(defgroup ox-pynb-settings nil
  "Org-mode export settings for pynb backend"
  :group 'org-export)

(defcustom ox-pynb-headline-format-alist
  '((1 . "#")
    (2 . "##")
    (3 . "###"))
  "Dictionary defining tags for formatting headlines to HTML."
  :group 'ox-pynb-settings
  :type 'alist)

(defun pynb-inner-template (contents info)
  "Return document body after HTML conversion.  CONTENTS is the
transcoded contents string.  INFO is a plist holding export
option"
  (contents))

(defun pynb-section (section contents info)
  "Return SECTION..."
  (pynb-cell-markdown contents))

(defun pynb-format-string-list-element (string)
  "Applies double quotes, comma, newline to STRING."
  (format "\"%s\"" string))

(defun pynb-format-contents (contents)
  "Format CONTENTS as string list."
  (mapconcat 'pynb-format-string-list-element
             (split-string contents "\n")
             ",\n"))

(defun pynb-cell (contents type &optional outputs-etc)
  "Return CONTENTS formatted as ipynb cell"
  (format "{\n  \"cell_type\": \"%s\",\n  \"metadata\": {},\n  \"source\": [%s]%s\n},"
          type
          (pynb-format-contents contents)
          (if outputs-etc (format ",\n  \"outputs\": [],\n\"execution_count\": 0")  "")))

(defun pynb-cell-markdown (contents)
  "Return CONTENTS formatted as an ipynb markdown cell."
  (pynb-cell contents "markdown"))

(defun pynb-cell-python (contents)
  "Return CONTENTS formatted as an ipynb python code cell."
  (pynb-cell contents "code" t))

(defun all-but-last-char (string)
  "Returns all but the last character of STRING"
  (substring string 0 (- (length string) 2 )))

(defun pynb-template (contents info)
  "Return complete document string after HTML conversion.
CONTENTS is the transcoded contents string.  INFO is a plist
holding export options."
  (let* ((title (plist-get info :title))
         (formatted-contents (concat
                             (pynb-cell-markdown (format "# %s" (org-export-data title info)))
                             (all-but-last-char contents))))
    (format "{\n\"cells\": [\n%s\n],\"metadata\": {\"kernelspec\": {\"display_name\": \"Python 3\", \"language\": \"python\", \"name\":\"python3\"}, \"language_info\": {\"codemirror_mode\": {\"name\":\"ipython\",\"version\":3}, \"file_extension\": \".py\", \"mimetype\":\"text/x-python\",\"name\":\"python\",\"nbconvert_exporter\":\"python\",\"pygments_lexer\":\"ipython3\", \"version\":\"3.8.3\"}},\"nbformat\":4,\"nbformat_minor\": 4\n}"
            formatted-contents)))




(defun org-pynb-headline (headline contents info)
  "Transcode a HEADLINE element from Org to HTML.
CONTENTS holds the contents of the headline.  INFO is a plist
holding contextual information."
  (let ((title (car (org-element-property :title headline)))
        (level (org-export-get-relative-level headline info)))
    (format
     "%s\n%s"
     (pynb-cell-markdown
      (format "%s %s" (make-string (+ level 1) ?#) title))
     (or contents ""))))

;;   (let* ((level (org-export-get-relative-level headline info))
;; 	 ;; TODO: make level non-relative
;; 	 (text (org-export-data (org-element-property :title headline) infoy))
;; 					;(tag (assoc level ox-pynb-headline-format-alist)))
;; 	 (tag (cond ((= level 1) "##")
;; 		    ((= level 2) "###")
;; 		    ((= level 3) "####")
;; 		    (else ""))) ;; TODO fix headline assoc list?
;;     (format "%s %s\n\n%s" tag text (or contents "")))))

(defun org-pynb-src-block (src-block contents info)
  "Return CONTENTS of SRC-BLOCK formatted as a python code block, if language is python, else as a markdown block with code formatting."
  (let ((lang (org-element-property :language src-block))
        (code (org-element-property :value src-block)))
    (if (string-equal lang "python")
        (pynb-cell-python code)
      (pynb-cell-markdown (format "```%s\n%s\n```" lang code)))))


(org-export-define-derived-backend 'pynb 'ascii
  :menu-entry '(?i "Export to IPythonNotebook"
                   (
                    (?b "As .ipynb buffer" org-pynb-export-to-buffer)
                    (?f "As .ipynb file" org-pynb-export-to-file)
                    (?F "As .ipynb file and open" org-pynb-export-to-file-and-open)
                    ))
                                        ;(lambda (a s v b) (org-pynb-export-as-pynb a s v)))
                   ;org-pynb-export-to-buffer)
  :translate-alist '((inner-template . plain2)
                     (template . pynb-template)
		     (paragraph . pynb-section)
		     (headline . org-pynb-headline)
                     (src-block . org-pynb-src-block)
                     ))

(defun org-pynb-export-to-buffer (&optional async subtreep visible-only body-only)
  "  "
  (interactive)
  (org-export-to-buffer 'pynb "*Org PyNB Export*"
    async subtreep visible-only body-only nil (lambda () (json-mode))))

(defun org-pynb-export-to-file (&optional async subtreep visible-only body-only)
  "  "
  (interactive)
  (let ((fname (org-export-output-file-name ".ipynb" subtreep)))
    (org-export-to-file 'pynb fname
        async subtreep visible-only body-only nil (lambda (f) fname))))

(defun org-pynb-export-to-file-and-open (&optional async subtreep visible-only body-only)
  "  "
  (interactive)
  (org-open-file
   (org-pynb-export-to-file async subtreep visible-only body-only)))





(provide 'ox-pynb)
;;; ox-pynb.el ends here
