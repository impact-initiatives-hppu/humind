# Releasing humind

`humind` is **not distributed on CRAN** — users install a tagged version
straight from GitHub (see README installation instructions). That removes
CRAN-only steps (win-builder, `cran-comments.md`, `devtools::submit_cran()`)
from the process below, but everything else follows the same shape as the
standard R-package release workflow (see [r-pkgs.org release
chapter](https://r-pkgs.org/release.html), [rOpenSci dev
guide](https://devguide.ropensci.org/maintenance_releases.html), and
`usethis::use_release_issue()`), adapted to this repo's own conventions.

## Versioning scheme

`humind` uses **calendar versioning**: `YYYY.N.N`, e.g. `2025.1.4`.

- First number: the year.
- Second number: increments for a release cycle that introduces
  programmatic/indicator-logic changes (e.g. the annual MSNI framework
  update). Dev branches for an upcoming cycle are named `devYYYY.N.0`
  (e.g. `dev2026.2.0`) — this pattern is what triggers CI on
  `.github/workflows/check-standard.yaml`.
- Third number: patch releases — bug fixes and small enhancements within
  a cycle, no indicator-logic changes.

Look at existing tags (`git tag -l`) and `NEWS.md` for precedent before
picking the next version number.

## Checklist

### 1. Before you start

- [ ] `git checkout main && git pull` (or the relevant `devYYYY.N.0` branch
      if you're releasing a new cycle before merging to `main`).
- [ ] Confirm CI is green on the branch you're releasing from:
      `check-standard`, `test-coverage`.
- [ ] Decide the version number (see scheme above) and whether this release
      contains **breaking changes** to indicator logic or output columns —
      if so, this needs to be called out prominently (see step 3).
- [ ] Skim merged PRs / commits since the last tag for anything not yet
      reflected in `NEWS.md`:
      `git log vLAST_TAG..HEAD --oneline`

### 2. Update DESCRIPTION

- [ ] Bump `Version:` in `DESCRIPTION` to the new `YYYY.N.N`.

### 3. Write the NEWS.md entry

- [ ] Generate a first draft of the commit list with
      [`git-cliff`](https://git-cliff.org/), scoped to everything since the
      last tag:
      ```sh
      git cliff vLAST_TAG..HEAD --unreleased
      ```
      This groups commits by conventional-commit type (`feat`, `fix`,
      `refactor`, `docs`, `test`, `chore`, ...), which is a fast way to see
      everything that landed and avoid missing a PR — but its output is a
      starting point, not the final text. It won't know about
      "Programmatic Changes" (indicator/framework changes) or which fixes
      are actually **breaking** — that categorization still needs a human
      pass.

- [ ] Rewrite/reorganize the `git-cliff` draft into a new section at the
      top of `NEWS.md` (above the previous release, below the
      `# humind (development version)` header — see past entries for the
      house style). Use this structure, dropping sections that don't
      apply:

```markdown
# humind YYYY.N.N

<One or two sentences summarizing the release.>

---

## <Year> Programmatic Changes   <!-- only for cycles with indicator/logic changes -->

* Describe terminology, threshold, or framework changes by sector.

---

## Codebase Changes

### New Features
### Enhancements
### Bug Fixes
### Testing
### Documentation
### Dependency Management
### Breaking Changes
```

- [ ] Reference GitHub issue/PR numbers where relevant (`(#123)`).
- [ ] If any function was renamed, gained a required argument, or changed
      default output, it goes under **Breaking Changes** — no
      exceptions. This is what users scan for before upgrading.
- [ ] If the change originated from an `indicator_logic_change` issue,
      link it.

### 4. Regenerate docs

- [ ] `roxygen2::roxygenise()` (or comment `/document` on the PR to let CI
      do it via `.github/workflows/pr-commands.yaml`).
- [ ] `devtools::build_readme()` to regenerate `README.md` from
      `README.Rmd`.
- [ ] Update the install instructions in `README.Rmd`/`README.md` to
      reference the new tag:
      `devtools::install_github("impact-initiatives-hppu/humind@vYYYY.N.N")`.

### 5. Full check

- [ ] `devtools::check(remote = TRUE, manual = TRUE)` locally, or confirm
      the `check-standard` matrix (macOS/Windows/Ubuntu × release/oldrel-1/
      oldrel-2) is green on the PR.
- [ ] `devtools::spell_check()` / let the `.pre-commit-config.yaml` spell
      check hook run.
- [ ] Skim `pkgdown` reference site build for anything obviously broken.

### 6. Merge

- [ ] Open/merge the PR from the `devYYYY.N.N` (or feature) branch into
      `main`. Squash or merge per repo convention (see recent history —
      merge commits are the norm here).

### 7. Tag and release

- [ ] On `main`, after the merge:
  ```sh
  git checkout main && git pull
  git tag vYYYY.N.N
  git push origin vYYYY.N.N
  ```
- [ ] Create a GitHub Release for the tag (`gh release create vYYYY.N.N`
      or via the UI). Paste the `NEWS.md` section for this version as the
      release body — `git-cliff` can also render release-note-ready output
      directly (`git-cliff --tag vYYYY.N.N vLAST_TAG..HEAD`), but prefer
      the curated `NEWS.md` text since it's already been organized into
      the house categories. Lead with breaking changes if there are any.
- [ ] Confirm `pkgdown.yaml` redeployed the site on push to `main` (it
      runs automatically) and that the new version shows up in the site's
      changelog/reference.

### 8. Post-release

- [ ] Add a fresh, empty `# humind (development version)` section at the
      top of `NEWS.md` on `main` (or on the next `devYYYY.N.0` branch) so
      future commits have somewhere to land.
- [ ] If this release changes indicator logic/output columns, give the
      HPPU/MSNA user community a heads-up (Slack/email) pointing at the
      Breaking Changes section — these functions feed live assessments,
      silent upgrades are the main risk.

## References

- [R Packages (2e) — Releasing to CRAN](https://r-pkgs.org/release.html)
  (mostly CRAN-specific, but the version-bump/NEWS/tag sequence applies
  here too)
- [rOpenSci Dev Guide — Releasing a package](https://devguide.ropensci.org/maintenance_releases.html)
- [`usethis::use_release_issue()`](https://usethis.r-lib.org/reference/use_release_issue.html)
  and [`usethis::use_github_release()`](https://usethis.r-lib.org/reference/use_github_release.html)
- [tidyverse NEWS style guide](https://style.tidyverse.org/news.html)
- [git-cliff](https://git-cliff.org/) — changelog generator from conventional
  commits, used here to draft the NEWS.md/release-notes starting point
