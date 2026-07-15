# Add indicator for reduced Household CSI Score(rcsi)

Add indicator for reduced Household CSI Score(rcsi)

## Usage

``` r
add_rcsi(
  .dataset,
  fsl_rcsi_lessquality = "fsl_rcsi_lessquality",
  fsl_rcsi_borrow = "fsl_rcsi_borrow",
  fsl_rcsi_mealsize = "fsl_rcsi_mealsize",
  fsl_rcsi_mealadult = "fsl_rcsi_mealadult",
  fsl_rcsi_mealnb = "fsl_rcsi_mealnb"
)
```

## Arguments

- .dataset:

  Main Dataset

- fsl_rcsi_lessquality:

  Column representing question- During the last 7 days, were there days
  (and, if so, how many) when your household had to rely on less
  preferred and less expensive food to cope with a lack of food or money
  to buy it?

- fsl_rcsi_borrow:

  Column representing question- During the last 7 days, were there days
  (and, if so, how many) when your household had to borrow food or rely
  on help from a relative or friend to cope with a lack of food or money
  to buy it?

- fsl_rcsi_mealsize:

  Column representing question- During the last 7 days, were there days
  (and, if so, how many) when your household had to limit portion size
  of meals at meal times to cope with a lack of food or money to buy it?

- fsl_rcsi_mealadult:

  Column representing question- During the last 7 days, were there days
  (and, if so, how many) when your household had to restrict consumption
  by adults in order for small children to eat to cope with a lack of
  food or money to buy it?

- fsl_rcsi_mealnb:

  Column representing question - During the last 7 days, were there days
  (and, if so, how many) when your household had to reduce number of
  meals eaten in a day to cope with a lack of food or money to buy it?

## Value

A dataset with 7 additional columns: 5 weighted strategy columns
(`rcsi_*_weighted`), `fsl_rcsi_score`, and `fsl_rcsi_cat`.

## Examples

``` r
test_data <- data.frame(
  fsl_rcsi_lessquality = c(1, 2, 3, 1),
  fsl_rcsi_borrow = c(0, 0, 3, 0),
  fsl_rcsi_mealsize = c(4, 2, 6, 1),
  fsl_rcsi_mealadult = c(4, 3, 5, 0),
  fsl_rcsi_mealnb = c(2, 5, NA_integer_, 1)
)
add_rcsi(test_data)
#>   fsl_rcsi_lessquality fsl_rcsi_borrow fsl_rcsi_mealsize fsl_rcsi_mealadult
#> 1                    1               0                 4                  4
#> 2                    2               0                 2                  3
#> 3                    3               3                 6                  5
#> 4                    1               0                 1                  0
#>   fsl_rcsi_mealnb rcsi_lessquality_weighted rcsi_borrow_weighted
#> 1               2                         1                    0
#> 2               5                         2                    0
#> 3              NA                         3                    6
#> 4               1                         1                    0
#>   rcsi_mealsize_weighted rcsi_mealadult_weighted rcsi_mealnb_weighted
#> 1                      4                      12                    2
#> 2                      2                       9                    5
#> 3                      6                      15                   NA
#> 4                      1                       0                    1
#>   fsl_rcsi_score fsl_rcsi_cat
#> 1             19         High
#> 2             18       Medium
#> 3             NA         <NA>
#> 4              3    No to Low
```
