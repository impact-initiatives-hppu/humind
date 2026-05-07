# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this package does

`humind` is an R package that computes humanitarian composite indicators for IMPACT Multi-Sector Needs Assessments (MSNAs). It implements the **MSNI (Multi-Sectoral Needs Index) framework**: a pipeline that scores households across six sectors (Food Security, WASH, Health, SNFI, Education, Protection) and aggregates them into an overall needs index.

Food security functions (`add_hhs`, `add_fcs`, `add_rcsi`, `add_lcsi`, `add_fcm_phase`, `add_fclcm_phase`) are re-exported from the `impactR4PHU` package.

## Development commands

```r
# Load all functions without installing (primary dev workflow)
devtools::load_all()

# Run all tests
devtools::test()

# Run a single test file
testthat::test_file("tests/testthat/test-add_comp_wash.R")

# Regenerate documentation from roxygen2 comments
devtools::document()

# Full package check
devtools::check()

# Build pkgdown site
pkgdown::build_site()

# Check test coverage
covr::package_coverage()
```

Pre-commit hooks run automatically on commit (styler, roxygenize, lintr, spell-check, readme-rmd-rendered). Install them with `pre-commit install`.

`README.md` is generated from `README.Rmd` — edit the `.Rmd` file, never the `.md` directly.

## Architecture: Step–Composition pattern

Every function takes a data frame, adds new columns, and returns the data frame. Functions are designed to be chained with `|>`.

**Two-level pipeline for household-level composites:**

1. **Step functions** operate on individual-level loop data (e.g. `add_loop_healthcare_needed_cat(loop)`), then their outputs are aggregated to household level (typically by summing dummy variables) before being passed to composite functions.
2. **Composition functions** (`add_comp_*`) operate on household-level data. They accept column names as string arguments with sensible defaults matching IMPACT's standard variable naming conventions.

**The MSNI pipeline order:**

```
# Individual loop data
add_loop_healthcare_needed_cat(loop) → aggregate to HH level

# Household-level categorization (prerequisites for composites)
add_drinking_water_source_cat()
add_sanitation_facility_cat()
add_handwashing_facility_cat()
add_shelter_type_cat()
add_shelter_issue_cat()
add_occupancy_cat()
add_fds_cannot_cat()
add_prot_score_movement()
add_prot_score_practices()
add_prot_score_rights()

# Sectoral composites (each outputs *_score, *_in_need, *_in_severe_need)
add_comp_wash()
add_comp_health()
add_comp_snfi()
add_comp_edu()
add_comp_foodsec()
add_comp_prot()   # depends on add_prot_score_* having run first

# Final MSNI aggregation
add_msni()
```

Each `add_comp_*` function documents its prerequisites in the `@description` section.

## Scoring and thresholds

- Scores are on a **1–5 scale** (some composites use 1–4).
- `is_in_need(df, score)`: score ≥ 3 → 1, else 0.
- `is_in_severe_need(df, score)`: score ≥ 4 → 1, else 0.
- Binary output columns are named `*_in_need` and `*_in_severe_need` (not `*_in_acute_need` — retired in v2025.1.2).

## Coding conventions

### Function signatures

- All exported functions are named `add_*` (mutating) or `is_*` (binary classifiers).
- Every parameter that references a column name or a response value has a default matching IMPACT's standard survey variable naming. Functions work out-of-the-box on IMPACT-formatted data but are fully parameterizable.
- Never call `library()` inside package code — use `pkg::fun()` or `@importFrom`.

### Tidyverse style

- Use the native pipe `|>`, not `%>%`.
- Use `.by =` for per-operation grouping instead of `group_by() |> ... |> ungroup()`.
- Use `across()` with `.names = "mean_{.col}"` when applying functions to multiple columns.
- Use `map()` + `list_rbind()` instead of the superseded `map_dfr()`.
- Use `str_*` (stringr) for all string manipulation, not base R (`grepl`, `gsub`, `nchar`, etc.).
- Use `join_by()` syntax for joins, not character vectors (`by = c("a" = "b")`).

### rlang / dplyr patterns for programmatic column names

- Use `{{}}` (embrace) to forward function arguments into data-masking verbs:
  ```r
  my_fn <- function(df, var) df |> dplyr::mutate(out = {{ var }} * 2)
  ```
- Use `.data[[col]]` when `col` is a character variable — no ambiguity, no need for `rlang::sym()`:
  ```r
  df |> dplyr::summarise(mean = mean(.data[[col]]))
  ```
- Use `!!rlang::sym(col)` only when injection into a non-`.data` context is needed (e.g. inside `case_when()` conditions in existing code).
- Use `"{new_colname}" :=` (walrus + glue) when the output column name is a variable:
  ```r
  dplyr::mutate(df, "{new_colname}" := value)
  ```
- Document data-masking parameters with the tidy-eval tag:
  ```r
  #' @param var <[`data-masked`][dplyr::dplyr_data_masking]> Column to use.
  ```

### Validation and error handling

Internal validation helpers live in [R/internals.R](R/internals.R): `if_not_in_stop()`, `are_cols_numeric()`, `are_values_in_set()`, `are_values_in_range()`. Use these at the top of every function's `#------ Checks` section.

For user-facing errors, prefer `cli::cli_abort()` over `rlang::abort()` for richer inline markup. Use `rlang::warn()` for warnings. Structure error messages as a problem statement with bullet context:

```r
cli::cli_abort(c(
  "{.arg df} is missing required columns.",
  "x" = "Missing: {.val {missing_cols}}.",
  "i" = "Run {.fn if_not_in_stop} to diagnose."
))
```

Inline markup tokens: `{.arg x}` (argument), `{.fn foo}` (function), `{.val {v}}` (value), `{.cls {class(x)}}` (class), `{?s}` (pluralisation).

Section headers within function bodies use `#------` as a divider (e.g. `#------ Checks`, `#------ Compute`). Code style is enforced by `styler::tidyverse_style` via pre-commit.

## Testing conventions

- One test file per source file: `test-<function_name>.R`.
- Test data is constructed inline as `dplyr::tibble(...)` or via helpers in `tests/testthat/helper.R`.
  - `helper.R` contains `generate_survey_choice_combinations()` for exhaustively testing select-multiple question logic.
  - `helper-add_handwashing_facility_cat.R` contains shared fixtures for that function.
- Tests use `expect_equal()` for exact numeric output; `expect_true()` / `expect_false()` for logical checks.
- Use `expect_error(..., class = "error_class")` when testing for specific error types.
- Use `withr::local_*` functions for temporary state (options, env vars, temp files) — never clean up manually.
- Use `local_mocked_bindings()` (not deprecated `with_mock()`) for mocking.
- Always test NA propagation explicitly — the package has precise NA handling rules (e.g. DNK/PNTA handling differs by function).
- Each test must be self-contained: define all data inside the `test_that()` block, not in the surrounding scope.
