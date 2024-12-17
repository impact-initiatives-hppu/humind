#' Add a specific value to variables that were skipped
#'
#' @param df A data frame.
#' @param var The name of the variable that is used for the skip logic.
#' @param undefined A character vector of values that are considered as "undefined" and should not be replaced in follow-up variables.
#' @param sl_vars A character vector of variable names which were skipped and should be replaced with a value.
#' @param sl_value The value that should be added to the skipped variables.
#' @param suffix A suffix to add to the new variable names. Default to no suffix (empty string).
#'
#' @export
value_to_sl <- function(
    df,
    var,
    undefined = NULL,
    sl_vars,
    sl_value,
    suffix = ""
){

  #------ Checks

  # Check that var and sl_vars exists
  if_not_in_stop(df, c(var, sl_vars), "df")

  #------ Add value

  # Add sl_value across sl_vars if sl_vars is NA and var is not "undefined"
  df <- dplyr:: mutate(
    df,
    dplyr::across(
      dplyr::all_of(sl_vars),
        \(x) dplyr::case_when(
          is.na(x) & !(!!rlang::sym(var) %in% undefined) ~ sl_value,
          .default = x
        ),
      .names = "{.col}{suffix}"
    )
  )

  return(df)
}
