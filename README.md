
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
- Washington Group Short Set of questions (WG-SS).
- JMP ladders.
- Specific indicators related to the MSNI framework.

The package follows the ‘Step-Composition’ approach of IMPACT R
framework.

## Installation

You can install the latest stable version of `humind` from GitHub:

``` r
install.packages("devtools")
devtools::install_github("impact-initiatives-hppu/humind")
```

Education specific functions are stored in the education branch at the
moment. They will be added to the main branch with an upcoming
version/milestone.

**IMPORTANT**: The education branch is up-to-date with the main branch.

To install the education branch:

``` r
devtools::install_github("impact-initiatives-hppu/humind@education")
```

## Usage

Here’s a quick dummy example of how to use `humind`:

``` r
#loading the package, check install step above before if not installed!  
library(humind)

# Example usage (replace with the actual function name based on the desired output, check R directory for each function name)
dummy_data <- data.frame(
  dummy_variableA = c(1, 2, 3),
  dummy_variableB = c(2, 3, 1),
  dummy_variableC = c(0, 1, 2)
)

result <- dummy_function(dummy_data)
print(result)
```

For a general information and layout about each functions parameters,
check the [R Package Documentation](r_package_documentation.md)

## Issues and Feedback

If you encounter any issues or have feedback, and/or new features
suggestion, please [open an
issue](https://github.com/impact-initiatives-hppu/humind/issues/new/choose)
on our GitHub repository.

## Roadmap

We are actively developing `humind`. Expect potential breaking changes
as we roll out the first version of the package for 2024 MSNAs, based on
country testing and feedback.

THE PACKAGE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS
OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.

Check our [project
board](https://github.com/impact-initiatives-hppu/humind/projects) for
upcoming features and milestones.

## License

`humind` is released under the [MIT License](LICENSE.md).
