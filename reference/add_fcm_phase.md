# Add the food consumption matrix to the dataset

Add the food consumption matrix to the dataset

## Usage

``` r
add_fcm_phase(
  .dataset,
  fcs_column_name = "fsl_fcs_cat",
  rcsi_column_name = "fsl_rcsi_cat",
  hhs_column_name = "fsl_hhs_cat_ipc",
  hdds_column_name = "fsl_hdds_cat",
  fcs_categories_acceptable = "Acceptable",
  fcs_categories_poor = "Poor",
  fcs_categories_borderline = "Borderline",
  rcsi_categories_low = "No to Low",
  rcsi_categories_medium = "Medium",
  rcsi_categories_high = "High",
  hhs_categories_none = "None",
  hhs_categories_little = "Little",
  hhs_categories_moderate = "Moderate",
  hhs_categories_severe = "Severe",
  hhs_categories_very_severe = "Very Severe",
  hdds_categories_low = "Low",
  hdds_categories_medium = "Medium",
  hdds_categories_high = "High"
)
```

## Arguments

- .dataset:

  Main Dataset

- fcs_column_name:

  A string specifying the column name of the food consumption score in
  the dataset

- rcsi_column_name:

  A string specifying the column name of the reduced coping strategy
  index in the dataset

- hhs_column_name:

  A string specifying the column name of the household hunger scale in
  the dataset

- hdds_column_name:

  A string specifying the column name of the household dietary diversity
  score in the dataset

- fcs_categories_acceptable:

  The name of the value "Acceptable" (by default) in the fcs categories

- fcs_categories_poor:

  The name of the value "Poor" (by default) in the fcs categories

- fcs_categories_borderline:

  The name of the value "Borderline" (by default) in the fcs categories

- rcsi_categories_low:

  The name of the value "No to Low" (by default) in the rcsi categories

- rcsi_categories_medium:

  The name of the value "Medium" (by default) in the rcsi categories

- rcsi_categories_high:

  The name of the value "High" (by default) in the rcsi categories

- hhs_categories_none:

  The name of the value "None" (by default) in the hhs categories

- hhs_categories_little:

  The name of the value "Little" (by default) in the hhs categories

- hhs_categories_moderate:

  The name of the value "Moderate" (by default) in the hhs categories

- hhs_categories_severe:

  The name of the value "Severe" (by default) in the hhs categories

- hhs_categories_very_severe:

  The name of the value "Very Severe" (by default) in the hhs categories

- hdds_categories_low:

  The name of the value "Low" (by default) in the hdds categories

- hdds_categories_medium:

  The name of the value "Medium" (by default) in the hdds categories

- hdds_categories_high:

  The name of the value "High" (by default) in the hdds categories

## Value

this function returns a dataframe with a column called fc_cell that
includes values from 1 to 45 representing the Food Consumption Score
Matrix and the fc_phase column that includes the different 5 phases of
food consumption

## Examples

``` r
test_data <- data.frame(
  fsl_fcs_cat = c("Acceptable", "Poor", "Borderline", "Acceptable"),
  fsl_rcsi_cat = c("No to Low", "Medium", "No to Low", "High"),
  fsl_hhs_cat = c("None", "Little", "Severe", "Very Severe"),
  fsl_hdds_cat = c("Low", "High", "Medium", "High")
)
add_fcm_phase(test_data,
  fcs_column_name = "fsl_fcs_cat",
  rcsi_column_name = "fsl_rcsi_cat",
  hhs_column_name = "fsl_hhs_cat",
  hdds_column_name = "fsl_hdds_cat",
  fcs_categories_acceptable = "Acceptable",
  fcs_categories_poor = "Poor",
  fcs_categories_borderline = "Borderline",
  rcsi_categories_low = "No to Low",
  rcsi_categories_medium = "Medium",
  rcsi_categories_high = "High",
  hhs_categories_none = "None",
  hhs_categories_little = "Little",
  hhs_categories_moderate = "Moderate",
  hhs_categories_severe = "Severe",
  hhs_categories_very_severe = "Very Severe",
  hdds_categories_low = "Low",
  hdds_categories_medium = "Medium",
  hdds_categories_high = "High"
)
#>   fsl_fcs_cat fsl_rcsi_cat fsl_hhs_cat fsl_hdds_cat fsl_fc_cell fsl_fc_phase
#> 1  Acceptable    No to Low        None          Low           1   Phase 1 FC
#> 2        Poor       Medium      Little         High          27   Phase 3 FC
#> 3  Borderline    No to Low      Severe       Medium           9   Phase 3 FC
#> 4  Acceptable         High Very Severe         High          35   Phase 4 FC
```
