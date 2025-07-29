
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

`humind` provides functions to compose usual humanitarian composite
indicators related to IMPACT Multi-Sector Needs Assessments (MSNAs).
Such as:

- Food security indicators (rCSI, LCSI, HHS, FCS).
- JMP ladders.
- Specific indicators related to the MSNI framework.

The package follows the ‘Step - Composition’ approach of IMPACT R
framework.

## Installation

You can install the latest stable version of `humind` from GitHub:

``` r
install.packages("devtools")
devtools::install_github("impact-initiatives-hppu/humind")
```

## New Programmatic Changes in 2025:

- **Protection**: complete ravamp, based on a series of new Tier 1
  indicators related to Protection Needs.

- **SNFI**:

  - Changes to the number of shelter issues and their mapping to the FW
    (from 8 to 11 total issues).
  - Inclusion of one additional indicator to the security of tenure
    dimension: `hlp_eviction_risk.`
  - Hygiene indicator removed from the FDS series - making the total
    number of domestic tasks (and lighting) equal to 4 instead of 5.
  - Optional shelter damages component added.

- **Health**: removal of the WGQs from the framework.

- **WASH**: small changes to incorporate the self-reported variants and
  map them to the JMP classifications.

- **Food Security**: new additional step to analyze the impact of
  livelihood coping strategies on Food Consumption (changes done in
  [impactR4PHU](https://github.com/impact-initiatives/impactR4PHU) and
  reflected in humind).

- **Education**: small changes to indicator naming to reflect “direct
  attack on education”. Indicator name was `edu_disrupted_occupation`
  and is now called `edu_disrupted_attack.`

## 📌 Issues and Feedback

To help us respond efficiently, please select the most appropriate
template when opening an issue:

- **[🐛Bug
  report](https://github.com/impact-initiatives-hppu/humind/issues/new?template=bug-report.yml&labels=bug,triage)**
  – Use this if you’ve found a **reproducible error or unexpected
  behavior** in the code. Include clear steps and environment details.

- **[🧮 Indicator Logic
  Change](https://github.com/impact-initiatives-hppu/humind/issues/new?template=indicator_logic_change.yml&labels=indicator-logic)**
  – Use this for **adding, updating, or fixing logic related to
  indicators, scoring, or categorization** in the code.

- **[✨ Feature
  request](https://github.com/impact-initiatives-hppu/humind/issues/new?template=feature_request.yml&labels=enhancement)**
  – Use this to **suggest a new feature or an enhancement** to existing
  functionality.

- **[📖 Documentation
  request](https://github.com/impact-initiatives-hppu/humind/issues/new?template=documentation_request.yml&labels=documentation)**
  – Use this for **incorrect, missing, or unclear documentation** that
  needs an update.

**Not sure where your issue fits?**  
Open a **[blank
issue](https://github.com/impact-initiatives-hppu/humind/issues/new)**
and provide as much detail as possible.

------------------------------------------------------------------------

## License

`humind` is released under the [MIT License](LICENSE.md).
