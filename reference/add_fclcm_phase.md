# Calculating the Food Consumption-Livelihood Coping Matrix

Calculating the Food Consumption-Livelihood Coping Matrix

## Usage

``` r
add_fclcm_phase(
  .dataset,
  fc_phase_var = "fsl_fc_phase",
  fc_phase_1 = "Phase 1 FC",
  fc_phase_2 = "Phase 2 FC",
  fc_phase_3 = "Phase 3 FC",
  fc_phase_4 = "Phase 4 FC",
  fc_phase_5 = "Phase 5 FC",
  lcs_cat_var = "fsl_lcsi_cat",
  lcs_cat_none = "None",
  lcs_cat_stress = "Stress",
  lcs_cat_crisis = "Crisis",
  lcs_cat_emergency = "Emergency"
)
```

## Arguments

- .dataset:

  Main Dataset

- fc_phase_var:

  Column name containing food consumption phase.

- fc_phase_1:

  The name of the value "Phase 1 FC" (by default) in the food
  consumption phase.

- fc_phase_2:

  The name of the value "Phase 2 FC" (by default) in the food
  consumption phase.

- fc_phase_3:

  The name of the value "Phase 3 FC" (by default) in the food
  consumption phase.

- fc_phase_4:

  The name of the value "Phase 4 FC" (by default) in the food
  consumption phase.

- fc_phase_5:

  The name of the value "Phase 5 FC" (by default) in the food
  consumption phase.

- lcs_cat_var:

  Column name containing livelihood coping category.

- lcs_cat_none:

  The name of the value "None" (by default) in the livelihood coping
  category.

- lcs_cat_stress:

  The name of the value "Stress" (by default) in the livelihood coping
  category.

- lcs_cat_crisis:

  The name of the value "Crisis" (by default) in the livelihood coping
  category.

- lcs_cat_emergency:

  The name of the value "Emergency" (by default) in the livelihood
  coping category.

## Value

Returns a dataframe with a additional column for FCLC phase.

## Examples

``` r
test_df <- data.frame(
  fsl_lcsi_cat = c("None", "Stress"),
  fsl_fc_phase = c("Phase 1 FC", "Phase 2 FC")
)
test_df |> add_fclcm_phase()
#>   fsl_lcsi_cat fsl_fc_phase  fclcm_phase
#> 1         None   Phase 1 FC Phase 1 FCLC
#> 2       Stress   Phase 2 FC Phase 2 FCLC
```
