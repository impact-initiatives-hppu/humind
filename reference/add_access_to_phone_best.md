# Add Best Phone Access and Coverage Information

This function recodes the best type of phone accessible in the household
and the coverage network type. It provides two main functions:

1.  `add_access_to_phone_best()`: Recodes the best type of phone
    accessible in the household.

2.  `add_access_to_phone_coverage()`: Recodes the coverage network type
    and the best type of phone owned in the household.

## Usage

``` r
add_access_to_phone_best(
  df,
  access_to_phone = "etc_access_to_phone",
  none = "none",
  smartphone = "smartphone",
  feature_phone = "feature_phone",
  basic_phone = "basic_phone",
  dnk = "dnk",
  pnta = "pnta",
  sep = "/"
)

add_access_to_phone_coverage(
  df,
  coverage_network_type = "etc_coverage_network_type",
  coverage_none = "no_coverage",
  coverage_no_internet = c("only_sms", "voice_sms", "only_voice"),
  coverage_yes_internet = c("voice_sms_internet", "only_internet"),
  coverage_undefined = c("dnk", "pnta"),
  access_to_phone_best = "etc_access_to_phone_best",
  access_to_phone_none = "none",
  access_to_basic_phone = "basic_phone",
  access_to_feature_phone = "feature_phone",
  access_to_smartphone = "smartphone",
  access_to_undefined = "undefined"
)
```

## Arguments

- df:

  The input data frame

- access_to_phone:

  The name of the column that contains the access to phone information.

- none:

  The value for no phone.

- smartphone:

  The value for smartphone.

- feature_phone:

  The value for feature phone.

- basic_phone:

  The value for basic phone.

- dnk:

  The value for do not know.

- pnta:

  The value for prefer not to answer.

- sep:

  Separator for the binary columns.

- coverage_network_type:

  Network coverage column.

- coverage_none:

  Value for no coverage.

- coverage_no_internet:

  Vector of values for no internet.

- coverage_yes_internet:

  Value for yes internet.

- coverage_undefined:

  Vector of values for do not know.

- access_to_phone_best:

  The name of the column that contains the access to phone information.

- access_to_phone_none:

  Value for no phone.

- access_to_basic_phone:

  Value for basic phone.

- access_to_feature_phone:

  Value for feature phone.

- access_to_smartphone:

  Value for smartphone.

- access_to_undefined:

  Value for undefined.

## Value

A data frame with an additional column 'etc_access_to_phone_best'
containing the recoded best type of phone accessible.

A data frame with an additional column 'etc_access_to_phone_coverage'
containing the recoded coverage and phone access information.
