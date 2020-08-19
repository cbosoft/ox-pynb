# ox-pynb

Simple exporter for Emacs' org-mode that converts an org document into a Jupyter
Notebook.

# Installation

Clone this repo, then copy the file `ox-pynb.el` to your emacs load path, or add
the path to `ox-pynb.el` to your load paths.

# Limitations

The conversion to .ipynb/json is a bit cave-person-ish, so lists don't work yet.

 - This means that having lists:
  ```python
with source```
  - embedded in them, **are a no go** at the moment.

However, headings/subheadings are fine.

If anything else doesn't work for you, please open an issue.
