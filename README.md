
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

- Specific indicators related to the MSNI framework: Sectoral
  Composites, MSNI Metrics and all recoding of indicators needed for
  these.
- Food security indicators (rCSI, LCSI, HHS, FCS).
- Recoding of WASH indicators to JMP classifications.

The package follows the ‘Step - Composition’ approach of IMPACT R
framework.

## Installation

You can install the latest stable version of `humind` from GitHub:

``` r
# install.packages("devtools")
devtools::install_github("impact-initiatives-hppu/humind@v2025.1.1")
```

To confirm that you have the correct version, you should try the
following:

``` r
packageVersion("humind")
# v2025.1.1
```

## 📚 Guidance Note

A comprehensive **Guidance Note** is available
[here](https://acted.sharepoint.com/sites/IMPACT-Humanitarian_Planning_Prioritization/SitePages/MSNA%20analysis%20(LSG-MSNi).aspx?xsdata=MDV8MDJ8fDE5ZmZkZDBlMTgyYTQ5MWUxNjUzMDhkZGNlNmVmOGYxfGQyMDBlOTAzMTliMDQ1MmViZDIxZDFhYTAxMTM5MGQ1fDB8MHw2Mzg4OTM2OTgxNzQ3NTIzMzl8VW5rbm93bnxWR1ZoYlhOVFpXTjFjbWwwZVZObGNuWnBZMlY4ZXlKRFFTSTZJbFJsWVcxelgwRlVVRk5sY25acFkyVmZVMUJQVEU5R0lpd2lWaUk2SWpBdU1DNHdNREF3SWl3aVVDSTZJbGRwYmpNeUlpd2lRVTRpT2lKUGRHaGxjaUlzSWxkVUlqb3hNWDA9fDF8TDJOb1lYUnpMekU1T21FM01HUmpZV0V4TURVNU5qUTVaV0ZpTXpRek1HTmpPR1F3WWpVeU1UQXhRSFJvY21WaFpDNTJNaTl0WlhOellXZGxjeTh4TnpVek56Y3pNREUyTmpjMHw5Y2NhODkyYzY5Yzc0ZmM5YWFkZjA4ZGRjZTZlZjhmMHxjODMwNzNhMzEzYWM0MGQ3ODRjNDhlODNlM2ViNTMyNQ%3D%3D&sdata=UlNiOVVRdGoxSC9QYmg4SW1Hb1ppUmlCNi8wZ2xPMGZkdG8rYzcrU2ptND0%3D&ovuser=d200e903-19b0-452e-bd21-d1aa011390d5%2Cquentin.villotta%40impact-initiatives.org&OR=Teams-HL&CT=1753776647777&clickparams=eyJBcHBOYW1lIjoiVGVhbXMtRGVza3RvcCIsIkFwcFZlcnNpb24iOiI1MC8yNTA3MDMxODgwOSIsIkhhc0ZlZGVyYXRlZFVzZXIiOmZhbHNlfQ%3D%3D)
for all users of the `humind` package. This document provides essential
background on the **MSNI framework** and includes sector-specific
guidance. Each sector includes a **“Humind Data Workflow”** section,
guiding users through the necessary steps and highlighting the relevant
`humind` package functions to use.

> ⚠️ **Users are strongly encouraged to thoroughly read this document**
> — particularly the *Data Workflow* sections — before starting any
> implementation work with Humind

> 📌 *Note: A more technical documentation guide will soon be available,
> detailing the full MSNI analysis workflow using `humind`, including
> runnable code examples. This guide will be directly integrated into
> the GitHub project to streamline the process.*

## 📖 2025 Programmatic Changes

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

- **WASH**: small changes to incorporate the self-reported hygiene
  variants (availability of soap & water) and map them to the JMP
  classifications.

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

## ⚠️ Known Issues

### GitHub Credentials Error When Installing with devtools

When installing the package from GitHub using
`devtools::install_github()`, you may encounter an error such as:

``` r
# install.packages("devtools")
devtools::install_github("impact-initiatives-hppu/humind@v2025.1.1")

Using GitHub PAT from the git credential store.
Error : Failed to install 'unknown package' from GitHub:
  HTTP error 401.
  Bad credentials
```

This issue is typically caused by outdated or incorrect GitHub
credentials stored in R. For public repositories, no credentials are
required. To resolve this, you can either update your credentials or
delete the stored credentials using the following commands:

``` r
library(gitcreds)
gitcreds_delete()
```

After updating or deleting the credentials, retry the installation. This
should resolve the error for public repositories.

------------------------------------------------------------------------

## License

`humind` is released under the [MIT License](LICENSE.md).
