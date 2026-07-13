# Add Household Water Insecurity Experiences (HWISE) Score

Computes the total `hwise4_score` (0–12) from the four HWISE survey
items (water quantity), and maps it to a WASH component score for water
quantity (`comp_wash_score_water_quantity`, 1–5). The four items are
internally recoded to numeric scores but are only exposed in the output
(as `_score`-suffixed columns) when `.keep_recoded = TRUE`.

## Usage

``` r
add_hwise(
  .df,
  wash_hwise_drink = "wash_hwise_drink",
  wash_hwise_hands = "wash_hwise_hands",
  wash_hwise_plans = "wash_hwise_plans",
  wash_hwise_worry = "wash_hwise_worry",
  hwise_never = "never",
  hwise_rarely = "rarely",
  hwise_sometimes = "sometimes",
  hwise_often = "often",
  hwise_always = "always",
  hwise_dnk = "dnk",
  hwise_pnta = "pnta",
  .keep_recoded = FALSE
)
```

## Arguments

- .df:

  A data frame containing the four HWISE columns.

- wash_hwise_drink:

  Column name for: *"In the last 4 weeks, how frequently has there NOT
  been as much water to drink as you would like for you or anyone in
  your household?"*

- wash_hwise_hands:

  Column name for: *"In the last 4 weeks, how frequently have you or
  anyone in your household had to go without washing hands after dirty
  activities (e.g., defecating or changing diapers, cleaning animal
  dung) because of problems with water?"*

- wash_hwise_plans:

  Column name for: *"In the last 4 weeks how often did you have to
  change schedules or plans because of problems with water?"*

- wash_hwise_worry:

  Column name for: *"In the last 4 weeks how often did you or anyone in
  your household worry that you would not have enough water for all of
  your needs?"*

- hwise_never:

  Response code for "Never (0 days)" (scored 0).

- hwise_rarely:

  Response code for "Rarely (1–2 days)" (scored 1).

- hwise_sometimes:

  Response code for "Some days (3–10 days)" (scored 2).

- hwise_often:

  Response code for "Often (11–20 days)" (scored 3).

- hwise_always:

  Response code for "Always (more than 20 days)" (scored 3).

- hwise_dnk:

  Response code for "Don't know" (scored NA).

- hwise_pnta:

  Response code for "Prefer not to answer" (scored NA).

- .keep_recoded:

  Logical, whether to keep the recoded numeric HWISE columns (ending in
  `_score`) in the output data frame. Default is FALSE.

## Value

`.df` with new columns:

- The four HWISE columns recoded to numeric scores (0–3, NA for
  dnk/pnta), suffixed with `_score` (only kept in the output if
  `.keep_recoded = TRUE`).

- `hwise4_score`: row sum of the four recoded columns (0–12).

- `comp_wash_score_water_quantity`: WASH severity score (1–5): 1 = score
  0–3, 2 = 4–6, 3 = 7–8, 4 = 9–10, 5 = 11+.

## See also

[`add_comp_wash()`](https://impact-initiatives-hppu.github.io/humind/reference/add_comp_wash.md)

## Examples

``` r
df <- dplyr::tibble(
  wash_hwise_drink = c("never",     "sometimes", "often"),
  wash_hwise_hands = c("rarely",    "often",     "always"),
  wash_hwise_plans = c("sometimes", "often",     "always"),
  wash_hwise_worry = c("never",     "sometimes", "always")
)

result <- add_hwise(df)
dplyr::select(result, hwise4_score, comp_wash_score_water_quantity)
#> # A tibble: 3 × 2
#>   hwise4_score comp_wash_score_water_quantity
#>          <dbl>                          <dbl>
#> 1            3                              1
#> 2           10                              4
#> 3           12                              5

# keep the per-item recoded scores (ending in `_score`)
result_recoded <- add_hwise(df, .keep_recoded = TRUE)
dplyr::select(result_recoded, dplyr::matches("_score$"))
#> # A tibble: 3 × 5
#>   wash_hwise_drink_score wash_hwise_hands_score wash_hwise_plans_score
#>                    <dbl>                  <dbl>                  <dbl>
#> 1                      0                      1                      2
#> 2                      2                      3                      3
#> 3                      3                      3                      3
#> # ℹ 2 more variables: wash_hwise_worry_score <dbl>, hwise4_score <dbl>
```
