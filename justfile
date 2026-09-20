# hubertjan-blog — command documentation
#
# A Quarto website published to GitHub Pages (gh-pages branch of the public
# repo) and served at https://hubertjan.de (custom domain via the CNAME file,
# which is listed as a project resource in _quarto.yml so it survives every render).
#
# Requirements: quarto (https://quarto.org/docs/get-started/), git.
# Run `just` with no arguments to list every recipe.

# Show all available recipes.
default:
    @just --list

# --- Writing -----------------------------------------------------------------

# Live preview with hot reload; opens a browser at http://localhost:4200.
preview:
    quarto preview --port 4200

# Preview a single file (e.g. `just preview-file posts/welcome/index.qmd`).
preview-file file:
    quarto preview {{file}}

# Edit the resulting posts/<slug>/index.qmd, then drop images in the same folder.
# Scaffold a new post directory with front matter (e.g. `just new-post my-first-post`).
new-post slug:
    #!/usr/bin/env bash
    set -euo pipefail
    dir="posts/{{slug}}"
    if [ -e "$dir" ]; then
        echo "error: $dir already exists" >&2
        exit 1
    fi
    mkdir -p "$dir"
    cat > "$dir/index.qmd" <<EOF
    ---
    title: "{{slug}}"
    author: "Hubert Tomaszczak"
    date: "$(date +%Y-%m-%d)"
    categories: [news]
    image: ""
    draft: true
    ---

    Write here.
    EOF
    echo "created $dir/index.qmd"

# --- Building ----------------------------------------------------------------

# Render the whole site into _site/ (git-ignored).
render:
    quarto render

# Render a single file (e.g. `just render-file about.qmd`).
render-file file:
    quarto render {{file}}

# Useful for checking the final build exactly as GitHub Pages will serve it.
# Serve the already-rendered _site/ over plain HTTP, no Quarto involved.
serve port="8000":
    python3 -m http.server {{port}} --directory _site

# --- Publishing --------------------------------------------------------------

# Quarto renders into a worktree, commits, and pushes gh-pages for you —
# it does NOT push your main branch, so commit and `just push` separately.
# Render and deploy the site to the gh-pages branch.
publish:
    quarto publish gh-pages

# Same, but skip the confirmation prompt (for scripted/CI use).
publish-ci:
    quarto publish gh-pages --no-prompt

# Remotes: `private` (hubertjan-blog-private) is where day-to-day work lands —
# main tracks private/main and remote.pushDefault is set to private, so a bare
# `git push` goes there. `origin` (hubertjan-blog) is the public mirror; Quarto
# hard-codes `origin` for gh-pages, so it must stay the public repo.

# Commit and push source changes to the private repo (e.g. `just push "Add post about X"`).
push message:
    git add -A
    git commit -m "{{message}}"
    git push private main

# Mirror main to the public repo once the work is ready to be seen.
sync:
    git push origin main

# Show commits on main that are in the private repo but not yet in the public one.
unsynced:
    git fetch origin main
    git log --oneline origin/main..main

# The full loop: publish the built site, push to private, then sync to public.
ship message: publish (push message) sync

# --- Maintenance -------------------------------------------------------------

# Print the Quarto version and where it is installed.
version:
    quarto --version
    @which quarto

# Show environment details Quarto sees (useful when debugging renders).
check:
    quarto check

# Note: this also drops the freeze cache, so the next render
# re-executes every code cell in posts/.
# Remove build output and Quarto's caches.
clean:
    rm -rf _site .quarto
    find . -name '.DS_Store' -delete

# Show what is currently deployed on the gh-pages branch.
deployed:
    git fetch origin gh-pages
    git log -1 --stat origin/gh-pages
