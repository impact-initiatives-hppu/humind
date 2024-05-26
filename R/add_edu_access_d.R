#' Add education access dummy
#'
#' @param df A data frame of individual-level data.
#' @param edu_access Column name for education access
#' @param yes Value for yes
#' @param no Value for no
#' @param undefined Vector of undefined responses
#' @param schooling_age_dummy Column name for the dummy variable of schooling age
#'
#' @export
add_edu_access_d <- function(df,
                             edu_access = "edu_access",
                             yes = "yes",
                             no = "no",
                             undefined = c("pnta", "dnk"),
                             schooling_age_dummy = "ind_age_5_18"){

  #------ Checks

  # Check if the variable is in the data frame
  if_not_in_stop(df, c(edu_access, schooling_age_dummy), "df")

  # Check if values are in set
  are_values_in_set(df, edu_access, c(yes, no, undefined))
  are_values_in_set(df, schooling_age_dummy, c(0,1))

  # Check that yes and no are of length &
  if (length(yes) != 1 | length(no) != 1) {
    stop("yes and no must be of length 1.")
  }

  # Check if ind_age is numeric
  are_cols_numeric(df, schooling_age_dummy)

  #------ Compute

  # Add dummy
  df <- dplyr::mutate(
    df,
    edu_access_d = dplyr::case_when(
      !!rlang::sym(schooling_age_dummy) == 0 ~ NA_integer_,
      !!rlang::sym(edu_access) == yes & !!rlang::sym(schooling_age_dummy) == 1 ~ 1,
      !!rlang::sym(edu_access) == no & !!rlang::sym(schooling_age_dummy) == 1 ~ 0,
      !!rlang::sym(edu_access) %in% undefined ~ 0,
      .default = NA_integer_
    )
  )

  return(df)

}
