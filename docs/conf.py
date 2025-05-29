import os
import sys

# -- Project information -----------------------------------------------------

project = 'wrftailor'
author = 'Amirhossein Nikfal'
copyright = '2024, Amirhossein Nikfal'
release = '2024'

# -- General configuration ---------------------------------------------------

extensions = [
    "myst_parser",
    "sphinx_copybutton",
    "sphinx.ext.autodoc",
    "sphinx.ext.autosectionlabel",
    "sphinx.ext.extlinks",
    "sphinx.ext.intersphinx",
]

templates_path = ["_templates"]
exclude_patterns = ["_build", "Thumbs.db", ".DS_Store"]
language = "en"
master_doc = "index"
default_role = "obj"

# -- HTML output -------------------------------------------------------------

html_theme = "pydata_sphinx_theme"
html_theme_options = {
    "default_mode": "dark",
}

html_static_path = ["_static"]
html_logo = "_static/logo.png"  # optional, if you have one
html_favicon = "_static/favicon.ico"  # optional, if you have one

# -- Myst options ------------------------------------------------------------

myst_enable_extensions = [
    "deflist",
]

# -- Intersphinx mappings ----------------------------------------------------

intersphinx_mapping = {
    "python": ("https://docs.python.org/3", None),
    "sphinx": ("https://www.sphinx-doc.org/en/master/", None),
}

# -- Suppress warnings -------------------------------------------------------

suppress_warnings = ["epub.unknown_project_files"]

