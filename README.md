
<!-- README.md is generated from README.Rmd. Please edit that file -->

# humind <a href="https://impact-initiatives-hppu.github.io/humind/"><img src="man/figures/logo.png" align="right" height="139" alt="humind website" /></a>

<!-- badges: start -->

[![R-CMD-check](https://github.com/impact-initiatives-hppu/humind/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/impact-initiatives-hppu/humind/actions/workflows/R-CMD-check.yaml)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![CRAN
status](https://www.r-pkg.org/badges/version/humind)](https://CRAN.R-project.org/package=humind)
[![Codecov test
coverage](https://codecov.io/gh/impact-initiatives-hppu/humind/branch/main/graph/badge.svg)](https://app.codecov.io/gh/impact-initiatives-hppu/humind?branch=main)
<!-- badges: end -->

`humind` provides functions to compose common humanitarian composite
indicators related to IMPACT Multi-Sector Needs Assessments (MSNAs),
including:

- MSNI framework indicators: sectoral composites, MSNI metrics, and all
  required recoding
- Food security indicators: rCSI, LCSI, HHS, FCS
- WASH indicator recoding to JMP classifications

The package follows the **Step – Composition** approach of the IMPACT R
framework.

## Installation

Install the latest tagged release from GitHub:

``` r
# install.packages("devtools")
devtools::install_github("impact-initiatives-hppu/humind@v2025.1.2")
```

Verify the version:

``` r
packageVersion("humind")
# v2025.1.2
```

## 📚 Guidance Note

A comprehensive **Guidance Note** is available
[here](https://acted.sharepoint.com/sites/IMPACT-Humanitarian_Planning_Prioritization/SitePages/MSNA%20analysis%20(LSG-MSNi).aspx).  
It provides essential background on the **MSNI framework** and
sector-specific guidance. Each sector includes a **“Humind Data
Workflow”** describing required steps and the relevant `humind`
functions.

> ⚠️ **Read the Guidance Note thoroughly**—especially the *Data
> Workflow* sections—before implementing analyses with `humind`.

> 📌 A technical documentation guide (full MSNI workflow with runnable
> examples) will be added to this repository.

------------------------------------------------------------------------

## 📖 2025 Programmatic Changes

### Cross-cutting

- **Terminology migration**: *acute need* → **severe need** (functions
  and outputs).

### MSNI & Sectoral Composites

- Consistent renaming of `*_in_acute_need` → **`*_in_severe_need`**
  across all domains.

### Protection

- Complete **revamp** based on a new series of Tier 1 indicators related
  to Protection needs.
- Refined NA handling in rights and practices composites: DNK/PNTA no
  longer collapse the entire composite; only affected sub-scores are
  nullified.

### WASH

- Expanded handwashing facility categorization via
  `add_handwashing_facility_cat()` with explicit soap-type handling and
  harmonized observed vs. reported rules.
- Incorporated self-reported hygiene variants (availability of soap &
  water) and mapped them to JMP classifications.

### Health

- Warnings and NA propagation in `add_loop_healthcare_needed_cat()` for
  inconsistent inputs.
- Removal of the WGQs from the framework.

### SNFI

- Shelter issues increased **from 8 to 11** and remapped to the
  framework.
- Added one indicator to the security of tenure dimension:
  `hlp_eviction_risk`.
- Hygiene indicator removed from the FDS series; domestic tasks
  (incl. lighting) now total **4** (was 5).
- Optional shelter damages component added.

### Food Security

- New analysis step to assess the impact of livelihood coping strategies
  on Food Consumption (implemented in
  [`impactR4PHU`](https://github.com/impact-initiatives/impactR4PHU) and
  reflected in `humind`).

### Education

- Indicator renamed from `edu_disrupted_occupation` to
  **`edu_disrupted_attack`** to reflect “direct attack on education”.

------------------------------------------------------------------------

## ⚠️ Breaking Changes in 2025.1.2

**Function rename**

- `is_in_acute_need()` → **`is_in_severe_need()`**

**Output schema**

- All `*_in_acute_need` outputs → **`*_in_severe_need`**  
  (MSNI, WASH, Health, Food Security, SNFI, Education, Protection).

**WASH**

- `add_comp_wash()` default parameter: `drinking_water_quantity` now
  defaults to **`wash_hwise_drink`** (was
  `wash_drinking_water_quantity`).
- `add_handwashing_facility_cat()` now requires soap-type columns/args
  (`soap_type_observed`, `soap_type_reported`) and accepts vectorized
  “no” codes.
- Classification rules tightened: non-qualifying or undefined soap types
  **demote `basic` → `limited`**; NA handling stricter in reported path.

**Protection**

- DNK/PNTA handling refined: composites are NA **only if both
  sub-dimensions are NA**.

**Healthcare**

- `add_loop_healthcare_needed_cat()` returns NA (with warnings) when
  `needed == yes` and `received == NA`.

------------------------------------------------------------------------

## 📌 Issues and Feedback

Choose the appropriate template when opening an issue:

- **[🐛 Bug
  report](https://github.com/impact-initiatives-hppu/humind/issues/new?template=bug-report.yml&labels=bug,triage)**
  – Reproducible errors or unexpected behavior.  
- **[🧮 Indicator Logic
  Change](https://github.com/impact-initiatives-hppu/humind/issues/new?template=indicator_logic_change.yml&labels=indicator-logic)**
  – Add, update, or fix logic for indicators, scoring, or
  categorization.  
- **[✨ Feature
  request](https://github.com/impact-initiatives-hppu/humind/issues/new?template=feature_request.yml&labels=enhancement)**
  – Suggest new features or enhancements.  
- **[📖 Documentation
  request](https://github.com/impact-initiatives-hppu/humind/issues/new?template=documentation_request.yml&labels=documentation)**
  – Report incorrect, missing, or unclear documentation.

**Not sure where it fits?**  
Open a **[blank
issue](https://github.com/impact-initiatives-hppu/humind/issues/new)**
with as much detail as possible.

------------------------------------------------------------------------

## ⚠️ Known Issues

### GitHub Credentials Error When Installing with devtools

When installing with `devtools::install_github()`, you may encounter:

``` r
> devtools::install_github("impact-initiatives-hppu/humind@v2025.1.2")
...
Error : Failed to install 'unknown package' from GitHub:
  HTTP error 401.
  Bad credentials
```

This is typically caused by outdated or incorrect GitHub credentials
stored in R. Public repositories do **not** require credentials. To
resolve:

``` r
library(gitcreds)
gitcreds_delete()
```

Then retry the installation.

------------------------------------------------------------------------

## License

`humind` is released under the [MIT License](LICENSE.md).
