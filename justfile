# arf is an R console (like Rscript); `-e` evaluates an expression and exits.
arf := "arf -e"

# List available recipes
default:
    @just --list

# Load all functions (dev workflow)
[group('dev')]
load:
    {{arf}} "devtools::load_all()"

# Run all tests
[group('dev')]
test:
    {{arf}} "devtools::test()"

# Run a single test file — usage: just test-file add_comp_wash
[group('dev')]
test-file name:
    {{arf}} "pkgload::load_all();testthat::test_file('tests/testthat/test-{{name}}.R')"

# Lint the package
[group('dev')]
lint:
    {{arf}} "lintr::lint_package()"

# Style the package
[group('dev')]
style:
    {{arf}} "styler::style_pkg()"

# Regenerate documentation
[group('docs')]
doc:
    {{arf}} "devtools::document()"

# Rebuild README.md from README.Rmd
[group('docs')]
readme:
    {{arf}} "devtools::build_readme()"

# Build pkgdown site
[group('docs')]
site:
    {{arf}} "pkgdown::build_site()"

# Spell check
[group('docs')]
spell:
    {{arf}} "spelling::spell_check_package()"

# Full package check
[group('check')]
check:
    {{arf}} "devtools::check()"

# Stricter pre-release check (remote dependencies + manual)
[group('check')]
check-release:
    {{arf}} "devtools::check(remote = TRUE, manual = TRUE)"

# Check test coverage
[group('check')]
coverage:
    {{arf}} "covr::package_coverage()"

# doc + check in sequence
[group('check')]
ci: doc check

# Bump the package version in DESCRIPTION — usage: just bump 2026.1.0
[group('release')]
bump version:
    {{arf}} "desc::desc_set_version('{{version}}')"

# Draft changelog content from conventional commits since the last tag (or a given ref) — usage: just changelog [from]
[group('release')]
changelog from="":
    #!/usr/bin/env bash
    set -euo pipefail
    # Default to everything since the most recent tag when no ref is given.
    from="{{from}}"
    if [ -z "$from" ]; then
        from=$(git describe --tags --abbrev=0)
    fi
    uvx git-cliff "$from"..HEAD --unreleased

# Print the NEWS.md section for a given version — usage: just news-section 2025.1.4
[group('release')]
news-section version:
    #!/usr/bin/env bash
    set -euo pipefail
    # Print from the "# humind <version>" heading up to (not including)
    # the next "# humind " heading.
    awk -v version="{{version}}" '
        $0 == "# humind " version { found = 1; print; next }
        found && /^# humind / { exit }
        found { print }
    ' NEWS.md

# Everything that should be green before opening a release PR, plus a changelog draft
[group('release')]
release-prep: doc check-release spell readme
    @just changelog

# Tag the current commit and push it — usage: just tag 2026.1.0
[group('release')]
tag version:
    git tag v{{version}}
    git push origin v{{version}}

# Create a GitHub release for a tag, using its NEWS.md section as the notes — usage: just release 2026.1.0
[group('release')]
release version:
    #!/usr/bin/env bash
    set -euo pipefail
    notes_file="$(mktemp)"
    just news-section {{version}} > "$notes_file"
    gh release create v{{version}} --title "humind {{version}}" --draft --notes-file "$notes_file"
    rm "$notes_file"
