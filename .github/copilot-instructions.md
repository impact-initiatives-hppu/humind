# humind code review instructions

humind computes MSNA/MSNI humanitarian indicators from Kobo XLSForm survey
data. It follows tidyverse conventions (dplyr, rlang, cli, checkmate,
testthat 3e). Do not assume the MSNA form or respondent data are otherwise
available; review against the contracts below.

## Source of truth for the MSNA form

The canonical machine-readable form is pinned to an immutable revision of
the `idem` repo:

https://raw.githubusercontent.com/impact-initiatives/idem/cce10b2bc306191bcb81d5722881d7f6c4a1a1ca/inst/extdata/form_required.json

This is the ONLY source of truth. Do not fetch `main`. Do not fall back to
an in-repo snapshot or any other copy. Fetch this exact pinned URL
(Playwright MCP or curl) whenever a PR touches inputs read directly from
the XLSForm.

Maintenance: when the MSNA form changes, bump the pinned ref in this file
(prefer an `idem` release tag once one contains the file; otherwise use a
commit SHA). A review can only be as current as this pin.

Schema:

- Questions live in a nested `children` tree.
- `name`: column name; `type`: e.g. "select one", "select multiple".
- `label`: per-language object; `bind`: relevant/constraint; `req`: "1".
- Select questions expose `list_name` and an embedded `choices` array;
  the top-level `choices` dict maps `list_name` -> [{name, label}].
- Answer codes are the `name` values in `choices`.

Verify:

1. Every referenced input column exists as a question `name` with the
   expected `type`.
2. Accepted answer options equal the `choices[list_name]` names (select_*
   only). Flag invented or misspelled codes, and missing valid codes.
3. `dnk`/`pnta`/`other` are handled as NA, never a substantive category.
4. Default parameter values match the form's question type/options.

If the pinned URL cannot be fetched, say so explicitly and do not perform
the form-alignment checks: report that the form could not be verified
rather than guessing from any other source.

## Upstream/downstream contracts

- Functions that consume intermediate `add_*`/`add_comp_*` outputs must
  match the upstream function's documented output domain, not the raw
  form. Verify accepted sets, column names, and value ranges upstream.
- When an upstream output changes (column names, categories, value
  domain, dnk/pnta handling), require integration tests with downstream
  consumers to be updated in the same PR. Flag stale chains.

## Correctness (highest priority)

- Every function consuming a categorical column MUST validate values with
  `are_values_in_set()` before coercion. Flag any `case_when()`/`match.arg()`
  on incoming values that can silently fall through to `0`, `NA`, or a
  default. (#787, #792)
- `match.arg()` must pass an explicit `choices =`; a lone argument silently
  collapses a vector default to its first element. (BUGS_FOUND.md, Bug 1)
- Do not use `NA` as a stand-in for a count of zero. Loop records left-joined
  to main can be unmatched; assert join coverage and coerce missing counts to
  `0` where zero is the valid answer. (#767, #770)
- Range/set checks over multiple columns must fail if ANY column violates the
  constraint: check each column, not a row-wise aggregate. (#798)
- Function defaults must stay in sync with the form and with the accepted
  sets used by downstream functions. Flag stale defaults. (#801)
- Require function arguments to be explicitly named and documented; flag
  positional arguments appended after an existing optional argument. (#793)

## R package conventions

- New/changed exported functions need roxygen docs (`@param`, `@return`,
  `@examples`) and a regenerated `man/` entry.
- User-facing errors use `cli::cli_abort()` with an actionable message and
  `call =`; never `stop()` with a bare string.
- Any user-visible change needs a `NEWS.md` entry under the current dev
  version.
- New behavior needs testthat coverage; modified lines should be covered.
- Do not add new dependencies without updating `DESCRIPTION`; prefer
  existing deps.
- Follow the repo `.lintr` config; don't reformat unrelated code.

## Review behavior

- Group related issues into one comment instead of repeating per line.
- Don't comment on generated files (`man/`, `docs/`, `NAMESPACE`) except
  to flag they are out of date.
- Severity: High = silent wrong indicator values, Medium = crash or broken
  edge case, Low = style/docs.
