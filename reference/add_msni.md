# Add Multi-Sectoral Needs Index (MSNI) Score and Related Indicators

This function calculates the MSNI score, determines if households are in
need or severe need, counts the number of sectoral needs, and creates a
sectoral needs profile.

Prerequisite functions:

- add_comp_edu.R

- add_comp_foodsec.R

- add_comp_health.R

- add_comp_prot.R

- add_comp_snfi.R

- add_comp_wash.R

## Usage

``` r
add_msni(
  df,
  comp_foodsec_score = "comp_foodsec_score",
  comp_snfi_score = "comp_snfi_score",
  comp_wash_score = "comp_wash_score",
  comp_prot_score = "comp_prot_score",
  comp_health_score = "comp_health_score",
  comp_edu_score = "comp_edu_score",
  comp_foodsec_in_need = "comp_foodsec_in_need",
  comp_snfi_in_need = "comp_snfi_in_need",
  comp_wash_in_need = "comp_wash_in_need",
  comp_prot_in_need = "comp_prot_in_need",
  comp_health_in_need = "comp_health_in_need",
  comp_edu_in_need = "comp_edu_in_need"
)
```

## Arguments

- df:

  A data frame containing sectoral composite scores and in-need
  indicators.

- comp_foodsec_score:

  Column name for the food security composite score.

- comp_snfi_score:

  Column name for the SNFI composite score.

- comp_wash_score:

  Column name for the WASH composite score.

- comp_prot_score:

  Column name for the protection composite score.

- comp_health_score:

  Column name for the health composite score.

- comp_edu_score:

  Column name for the education composite score.

- comp_foodsec_in_need:

  Column name for food security in need.

- comp_snfi_in_need:

  Column name for SNFI in need.

- comp_wash_in_need:

  Column name for WASH in need.

- comp_prot_in_need:

  Column name for protection in need.

- comp_health_in_need:

  Column name for health in need.

- comp_edu_in_need:

  Column name for education in need.

## Value

A data frame with 5 new columns:

- msni_score: The Multi-Sectoral Needs Index score.

- msni_in_need: Binary indicator for households in need.

- msni_in_severe_need: Binary indicator for households in severe need.

- sector_in_need_n: Number of sectoral needs identified.

- sector_needs_profile: Profile of sectoral needs identified (NA if no
  sectoral need is identified).
