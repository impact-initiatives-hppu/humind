
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

## Usage

Here’s a quick dummy example of how to use `humind`:

``` r
library(humind)
```

## Issues and Feedback

If you encounter any issues or have feedback, and/or new features
suggestion, please [open an
issue](https://github.com/impact-initiatives-hppu/humind/issues/new/choose)
on our GitHub repository.

Currently there are templates for the following types of issues:

- Bug Reports
- Feature Requests
- Documentation Requests
- Indicator Logic Change

## License

`humind` is released under the [MIT License](LICENSE.md).
