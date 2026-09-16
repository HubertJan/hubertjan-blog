# Vale config for technical, readable blog posts

1. Copy `.vale.ini`, `.gitignore`, and `styles/` into your blog's root folder.
2. Run `vale sync` once (downloads write-good and proselint into `styles/`).
3. Lint: `vale posts/my-post.qmd`, or use the Vale VSCode extension.

Custom rules live in `styles/Blog/`. Add technical terms to
`styles/config/vocabularies/Blog/accept.txt` (one per line, regex allowed).
To silence a rule, add e.g. `Blog.Wordiness = NO` to `.vale.ini`.

Note: Vale spellchecks top-level front matter values (e.g. `engine: knitr`).
Common Quarto values are already in `accept.txt`; add others there if flagged.
