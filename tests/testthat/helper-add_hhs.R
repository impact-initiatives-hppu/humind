generate_hhs_df <- function() {
  yn_codes <- c("yes", "no", NA_character_)
  freq_codes <- c("rarely", "sometimes", "often", NA_character_)

  # Valid yn x freq combinations: if yn == "yes", freq must have a value.
  # Otherwise (yn == "no" or NA), freq must be NA.
  pair <- tidyr::expand_grid(yn = yn_codes, freq = freq_codes) |>
    dplyr::filter(
      (!is.na(yn) & yn == "yes" & !is.na(freq)) |
        ((is.na(yn) | yn == "no") & is.na(freq))
    )

  tidyr::expand_grid(
    nofoodhh = pair,
    sleephungry = pair,
    alldaynight = pair
  ) |>
    tidyr::unpack(
      c(nofoodhh, sleephungry, alldaynight),
      names_sep = "_"
    ) |>
    dplyr::rename(
      fsl_hhs_nofoodhh = nofoodhh_yn,
      fsl_hhs_nofoodhh_freq = nofoodhh_freq,
      fsl_hhs_sleephungry = sleephungry_yn,
      fsl_hhs_sleephungry_freq = sleephungry_freq,
      fsl_hhs_alldaynight = alldaynight_yn,
      fsl_hhs_alldaynight_freq = alldaynight_freq
    )
}
