# Add LCSI

Function to calculate Livelihood Coping Strategy Index (LCSI)

## Usage

``` r
add_lcsi(
  .dataset,
  fsl_lcsi_stress1 = "fsl_lcsi_stress1",
  fsl_lcsi_stress2 = "fsl_lcsi_stress2",
  fsl_lcsi_stress3 = "fsl_lcsi_stress3",
  fsl_lcsi_stress4 = "fsl_lcsi_stress4",
  fsl_lcsi_crisis1 = "fsl_lcsi_crisis1",
  fsl_lcsi_crisis2 = "fsl_lcsi_crisis2",
  fsl_lcsi_crisis3 = "fsl_lcsi_crisis3",
  fsl_lcsi_emergency1 = "fsl_lcsi_emergency1",
  fsl_lcsi_emergency2 = "fsl_lcsi_emergency2",
  fsl_lcsi_emergency3 = "fsl_lcsi_emergency3",
  yes_val = "yes",
  no_val = "no_had_no_need",
  exhausted_val = "no_exhausted",
  not_applicable_val = "not_applicable"
)
```

## Arguments

- .dataset:

  Main Dataset

- fsl_lcsi_stress1:

  the name of the variable that indicates the first stress LCSI strategy

- fsl_lcsi_stress2:

  the name of the variable that indicates the second stress LCSI
  strategy

- fsl_lcsi_stress3:

  the name of the variable that indicates the third stress LCSI strategy

- fsl_lcsi_stress4:

  the name of the variable that indicates the fourth stress LCSI
  strategy

- fsl_lcsi_crisis1:

  the name of the variable that indicates the first crisis LCSI strategy

- fsl_lcsi_crisis2:

  the name of the variable that indicates the second crisis LCSI
  strategy

- fsl_lcsi_crisis3:

  the name of the variable that indicates the third crisis LCSI strategy

- fsl_lcsi_emergency1:

  the name of the variable that indicates the first emergency LCSI
  strategy

- fsl_lcsi_emergency2:

  the name of the variable that indicates the second emergency LCSI
  strategy

- fsl_lcsi_emergency3:

  the name of the variable that indicates the third emergency LCSI
  strategy

- yes_val:

  A character value in the dataset associated with "Yes, used this
  coping strategy in the last 30 days."

- no_val:

  A character value in the dataset associated with "No, have not used
  this coping strategy in the last 30 days."

- exhausted_val:

  A character value in the dataset associated with "No, haven't used in
  the last 30 days because I've exhausted this coping strategy in the
  last 6 or 12 months."

- not_applicable_val:

  A character value in the dataset associated with "This coping strategy
  is not applicable for the household."

## Value

Returns a dataframe with added columns for LCSI indicators.

- fsl_lcsi_x_yes : 1 means one of the of the x strategies was used
  (*yes_val*)

- fsl_lcsi_x_exhaust: 1 means one of the x strategies was exhausted and
  could not be used (*exhausted_val*)

- fsl_lcsi_x: 1 means one of the x strategies was if either used
  (*yes_val*) or exhausted (*exhausted_val*) Where x is stress, crisis
  or emergency

- fsl_lcsi_cat_yes : the highest category between the fsl_lcsi_x_yes

- fsl_lcsi_cat_exhaust: the highest category between the
  fsl_lcsi_x_exhaust

- fsl_lcsi_cat: the highest category between the fsl_lcsi_x

## Examples

``` r
{
  input_data1 <- data.frame(fsl_lcsi_stress1 = c("No", "No", "Exhausted", "Not Applicable", "No"),
  fsl_lcsi_stress2 = c("No", "Yes", "Not Applicable", "No", "No"),
  fsl_lcsi_stress3 = c("Not Applicable", "Not Applicable", "Yes", "No", "No"),
  fsl_lcsi_stress4 = c("Not Applicable", "No", "Yes", "Yes", "No"),
  fsl_lcsi_crisis1 = c("No", "Not Applicable", "Yes", "Exhausted", "No"),
  fsl_lcsi_crisis2 = c("No", "No", "No", "No", "No"),
  fsl_lcsi_crisis3 = c("No", "No", "Yes", "Not Applicable", "No"),
  fsl_lcsi_emergency1 = c("No", "Not Applicable", "Not Applicable", "No", "No"),
  fsl_lcsi_emergency2 = c("No", "Not Applicable", "Yes", "Not Applicable", "No"),
  fsl_lcsi_emergency3 = c("Not Applicable", "No", "Not Applicable", "No", "Exhausted"))

add_lcsi(.dataset = input_data1,
yes_val = "Yes",
no_val = "No",
exhausted_val = "Exhausted",
not_applicable_val = "Not Applicable")

}
#>   fsl_lcsi_stress1 fsl_lcsi_stress2 fsl_lcsi_stress3 fsl_lcsi_stress4
#> 1               No               No   Not Applicable   Not Applicable
#> 2               No              Yes   Not Applicable               No
#> 3        Exhausted   Not Applicable              Yes              Yes
#> 4   Not Applicable               No               No              Yes
#> 5               No               No               No               No
#>   fsl_lcsi_crisis1 fsl_lcsi_crisis2 fsl_lcsi_crisis3 fsl_lcsi_emergency1
#> 1               No               No               No                  No
#> 2   Not Applicable               No               No      Not Applicable
#> 3              Yes               No              Yes      Not Applicable
#> 4        Exhausted               No   Not Applicable                  No
#> 5               No               No               No                  No
#>   fsl_lcsi_emergency2 fsl_lcsi_emergency3 fsl_lcsi_stress_yes
#> 1                  No      Not Applicable                   0
#> 2      Not Applicable                  No                   1
#> 3                 Yes      Not Applicable                   1
#> 4      Not Applicable                  No                   1
#> 5                  No           Exhausted                   0
#>   fsl_lcsi_stress_exhaust fsl_lcsi_stress fsl_lcsi_crisis_yes
#> 1                       0               0                   0
#> 2                       0               1                   0
#> 3                       1               1                   1
#> 4                       0               1                   0
#> 5                       0               0                   0
#>   fsl_lcsi_crisis_exhaust fsl_lcsi_crisis fsl_lcsi_emergency_yes
#> 1                       0               0                      0
#> 2                       0               0                      0
#> 3                       0               1                      1
#> 4                       1               1                      0
#> 5                       0               0                      0
#>   fsl_lcsi_emergency_exhaust fsl_lcsi_emergency fsl_lcsi_cat_yes
#> 1                          0                  0             None
#> 2                          0                  0           Stress
#> 3                          0                  1        Emergency
#> 4                          0                  0           Stress
#> 5                          1                  1             None
#>   fsl_lcsi_cat_exhaust fsl_lcsi_cat
#> 1                 None         None
#> 2                 None       Stress
#> 3               Stress    Emergency
#> 4               Crisis       Crisis
#> 5            Emergency    Emergency
```
