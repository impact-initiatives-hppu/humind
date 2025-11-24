# Any barriers to accessing humanitarian assistance encountered

This function recodes any barriers to accessing humanitarian assistance
encountered from the barriers to accessing humanitarian assistance by
type indicator.

## Usage

``` r
add_barriers_assistance_any(
  df,
  barriers_assistance = "aap_barriers_assistance",
  none = "none",
  pnta = "pnta",
  dnk = "dnk"
)
```

## Arguments

- df:

  The input data frame

- barriers_assistance:

  The name of the column that contains the information about the
  barriers to accessing humanitarian assistance.

- none:

  The choice value that indicates that no barriers were encountered.

- pnta:

  The value value that indicates that the person prefers not to answer.

- dnk:

  The value value that indicates that the person does not know.

## Value

The data frame with the new variable
`aap_barriers_assistance_any_barrier`
