# add_fcs

add_fcs

## Usage

``` r
add_fcs(
  .dataset,
  cutoffs = c("normal", "alternative"),
  fsl_fcs_cereal = "fsl_fcs_cereal",
  fsl_fcs_legumes = "fsl_fcs_legumes",
  fsl_fcs_veg = "fsl_fcs_veg",
  fsl_fcs_fruit = "fsl_fcs_fruit",
  fsl_fcs_meat = "fsl_fcs_meat",
  fsl_fcs_dairy = "fsl_fcs_dairy",
  fsl_fcs_sugar = "fsl_fcs_sugar",
  fsl_fcs_oil = "fsl_fcs_oil"
)
```

## Arguments

- .dataset:

  Main Dataset

- cutoffs:

  either "normal", or "alternative". The default is set to normal

- fsl_fcs_cereal:

  the name of the variable that indicates the number of days cereals
  were consumed

- fsl_fcs_legumes:

  the name of the variable that indicates the number of days legumes
  were consumed

- fsl_fcs_veg:

  the name of the variable that indicates the number of days vegetables
  were consumed

- fsl_fcs_fruit:

  the name of the variable that indicates the number of days fruits were
  consumed

- fsl_fcs_meat:

  the name of the variable that indicates the number of days meat/fish
  were consumed

- fsl_fcs_dairy:

  the name of the variable that indicates the number of days dairy were
  consumed

- fsl_fcs_sugar:

  the name of the variable that indicates the number of days sugar was
  consumed

- fsl_fcs_oil:

  the name of the variable that indicates the number of days oil were
  consumed

## Value

the dataset with fsl_fcs_score and fsl_fcs_cat computed, as well as the
8 weighted food groups

## Examples

``` r
df1 <- data.frame(
  fsl_fcs_cereal = c(1, 2, 3, 2, 5, 6, 7),
  fsl_fcs_legumes = c(3, 4, 5, 6, 1, 6, 5),
  fsl_fcs_veg = c(3, 2, 1, 6, 5, 4, 3),
  fsl_fcs_fruit = c(1, 4, 6, 2, 2, 2, 4),
  fsl_fcs_meat = c(5, 4, 3, 2, 7, 4, 5),
  fsl_fcs_dairy = c(1, 2, 6, 7, 3, 4, 2),
  fsl_fcs_sugar = c(1, 7, 6, 5, 2, 3, 4),
  fsl_fcs_oil = c(2, 3, 6, 5, 1, 7, 4)
)
add_fcs(.dataset = df1,
  cutoffs = "normal"
)
#>   fsl_fcs_cereal fsl_fcs_legumes fsl_fcs_veg fsl_fcs_fruit fsl_fcs_meat
#> 1              1               3           3             1            5
#> 2              2               4           2             4            4
#> 3              3               5           1             6            3
#> 4              2               6           6             2            2
#> 5              5               1           5             2            7
#> 6              6               6           4             2            4
#> 7              7               5           3             4            5
#>   fsl_fcs_dairy fsl_fcs_sugar fsl_fcs_oil fcs_weight_cereal1 fcs_weight_legume2
#> 1             1             1           2                  2                  9
#> 2             2             7           3                  4                 12
#> 3             6             6           6                  6                 15
#> 4             7             5           5                  4                 18
#> 5             3             2           1                 10                  3
#> 6             4             3           7                 12                 18
#> 7             2             4           4                 14                 15
#>   fcs_weight_dairy3 fcs_weight_meat4 fcs_weight_veg5 fcs_weight_fruit6
#> 1                 4               20               3                 1
#> 2                 8               16               2                 4
#> 3                24               12               1                 6
#> 4                28                8               6                 2
#> 5                12               28               5                 2
#> 6                16               16               4                 2
#> 7                 8               20               3                 4
#>   fcs_weight_oil7 fcs_weight_sugar8 fsl_fcs_score fsl_fcs_cat
#> 1             1.0               0.5          40.5  Acceptable
#> 2             1.5               3.5          51.0  Acceptable
#> 3             3.0               3.0          70.0  Acceptable
#> 4             2.5               2.5          71.0  Acceptable
#> 5             0.5               1.0          61.5  Acceptable
#> 6             3.5               1.5          73.0  Acceptable
#> 7             2.0               2.0          68.0  Acceptable
```
