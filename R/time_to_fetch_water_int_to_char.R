#' Shape the time to fetch water to recoding state
#'
#' `time_to_fetch_water_int_to_char()` recodes the time to fetch water to categorical thresholds (incl. ) and `time_to_fetch_water_combine()` combines both the recoded integer variable and the character variable into one final character time to fetch water. See 2023 MSNA indicator bank for further information.
#' @param df A data frame.
#' @param var The name of the integer variable to be recoded.
#' @param int A vector of integer thresholds to define the thresholds.
#' @param char A vector of labels for each category. The labels correspond to the categories defined by the thresholds. The first label corresponds to values less than or equal to the first threshold, the second label corresponds to values greater than the first threshold and less than or equal to the second threshold, and so on.
#' @param int_dontknow A vector of integer values to be treated as "don't know" and replaced with `char_dontknow`.
#' @param char_dontknow A character value to be used as the label for "don't know" values.
#' @param sl_piped_into_dwelling A logical value indicating whether a skip logic was implemented using variable `var_piped_into_dwelling`. If `TRUE`, the function will recode the variable `var_piped_into_dwelling` to premises whenever it is `codes_piped_into_dwelling` before recoding `var`.
#' @param var_piped_into_dwelling The name of the variable to be recoded to premises.
#' @param codes_piped_into_dwelling A vector of codes to be recoded to premises.
#'
#' @return The input data frame with the recoded variable added as a new column.
#'
#'
#' @export
time_to_fetch_water_int_to_char <- function(df, var, int = c(0, 30, 60, 600), char = c("premises", "30_min_or_less", "more_than_30_to_1hr", "more_than_1hr"), int_dontknow = c(-999, 999), char_dontknow = "dnk", sl_piped_into_dwelling = TRUE, var_piped_into_dwelling = "drinking_water_source", codes_piped_into_dwelling = c("piped_into_dwelling")){

  #------ Checks
  # Check if the variable is in the data frame
  if_not_in_stop(df, var, "df")

  # Check if the thresholds are in ascending order
  if (any(diff(int) < 0)) {
    rlang::abort("The thresholds must be in ascending order.")
  }

  # Check if the thresholds are unique
  if (any(duplicated(int))) {
    rlang::abort("The thresholds must be unique.")
  }

  # Check if the char thresholds are unique
  if (any(duplicated(char))) {
    rlang::abort("The labels must be unique.")
  }

  # Check if the labels are the same length as the thresholds
  if (length(char) != length(int)) {
    rlang::abort("The labels must be the same length as the thresholds.")
  }

  # Check if int is integer
  are_cols_numeric(df, var)


  #------ Recode
  df <- dplyr::mutate(
    df,
    time_to_fetch_water_int_to_char = dplyr::case_when(
      # If skip logic added for piped into dwelling, need to recode to char[1]
      sl_piped_into_dwelling & !!rlang::sym(var_piped_into_dwelling) %in% codes_piped_into_dwelling ~ char[1],
      # Recode dontknow
      !!rlang::sym(var) %in% int_dontknow ~ char_dontknow,
      # Recode other values
      !!rlang::sym(var) < 0 ~ NA_character_,
      !!rlang::sym(var) ==  int[1] ~ char[1],
      !!rlang::sym(var) <= int[2] ~ char[2],
      !!rlang::sym(var) <= int[3] ~ char[3],
      !!rlang::sym(var) <= int[4] ~ char[4],
      .default = NA_character_
    )
  )

  return(df)
}


#' @rdname time_to_fetch_water_int_to_char
#'
#' @param var_int_to_char The recoded integer variable.
#' @param var_dontknow The character variable when do not know.
#' @param level_codes The character level codes.
#'
#' @export
time_to_fetch_water_combine <-  function(df, var_int_to_char = "time_to_fetch_water_int_to_char", var_dontknow = "time_to_fetch_water_dontknow", level_codes = c("premises, 30_min_or_less, more_than_30_to_1hr, more_than_1hr, dnk")){

#------ Checks

# Check if the variable is in the data frame
if_not_in_stop(df, var_int_to_char, "df")
if_not_in_stop(df, var_dontknow, "df")

# Check if level_codes are in the data frame
are_values_in_set(df, var_int_to_char, level_codes)
are_values_in_set(df, var_dontknow, level_codes)

#------ Combine

# var_int_to_char takes precedence over var_dontknow
# if both are NAs, then NA
# if var_int_to_char is NA, then var_dontknow
# if var_int_to_char is not NA, then var_int_to_char
df <- dplyr::mutate(
  df,
  time_to_fetch_water = dplyr::case_when(
    is.na(!!rlang::sym(var_int_to_char)) & is.na(!!rlang::sym(var_dontknow)) ~ NA_character_,
    is.na(!!rlang::sym(var_int_to_char)) ~ !!rlang::sym(var_dontknow),
    .default = !!rlang::sym(var_int_to_char)
  )
)

return(df)
}
