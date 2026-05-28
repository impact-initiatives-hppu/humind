#' ANA
#' 2025 INDICATOR ID: IND043
#' 2026 METRIC ID: TBD

#' @title Add Livestock Significant Decrease Dummy Variables
#'
#' @description For each livestock type, creates a binary (1/0/NA) dummy indicating whether the household experienced a significant decrease (greater than `threshold`) in livestock size between last year and now. Also produces a composite dummy that is 1 if any livestock type shows a significant decrease.
#'
#' If the required columns for a livestock type are absent from `df`, an error is thrown.
#'
#' @param df A data frame of household-level data.
#' @param livestock Character vector of livestock type names. Column names are built as `<prefix><type><n_now_suffix>` and `<prefix><type><n_ly_suffix>`.
#' @param prefix Column name prefix. Default `"fsl_"`.
#' @param n_now_suffix Suffix for the current count column. Default `"_n_now"`.
#' @param n_ly_suffix Suffix for the last-year count column. Default `"_n_ly"`.
#' @param threshold Proportion decrease threshold above which a decrease is considered significant. Default `0.5` (i.e. decrease of 50% or more).
#'
#' @return A data frame with additional columns:
#'
#' * `<prefix><type>_significant_decrease_d` for each livestock type: 1 if
#'   herd decreased by more than `threshold` proportion; 0 if not; NA if either
#'   count is NA or columns are absent.
#' * `<prefix>livestock_significant_decrease_d`: 1 if any type dummy is 1;
#'   0 if none is 1 and at least one is non-NA; NA if all type dummies are NA.
#'
#' @export
add_livestock_significant_decrease_d <- function(
  df,
  livestock = c(
    "oxen",
    "camel",
    "cattle",
    "horse",
    "mule",
    "sheep",
    "goat",
    "poultry"
  ),
  prefix = "fsl_",
  n_now_suffix = "_n_now",
  n_ly_suffix = "_n_ly",
  threshold = 0.5
) {
  #------ Checks

  # threshold is a single numeric value between 0 and 1
  if (
    !is.numeric(threshold) ||
      length(threshold) != 1 ||
      threshold < 0 ||
      threshold > 1
  ) {
    rlang::abort("threshold must be a single numeric value between 0 and 1.")
  }

  # all provided livestock columns must exist, be numeric and positive, one pass
  now_cols <- paste0(prefix, livestock, n_now_suffix)
  ly_cols <- paste0(prefix, livestock, n_ly_suffix)
  are_values_in_range(
    df,
    c(now_cols, ly_cols),
    lower = 0,
    upper = Inf
  )

  # prepare column names
  composite_col <- paste0(prefix, "livestock_significant_decrease_d")

  # warn if output columns already exist
  if (composite_col %in% colnames(df)) {
    rlang::warn(paste0(
      composite_col,
      " already exists in df. It will be replaced."
    ))
  }

  # warn if output col already exists
  dummy_cols <- paste0(prefix, livestock, "_significant_decrease_d")
  existing_dummy_cols <- dummy_cols[dummy_cols %in% colnames(df)]
  if (length(existing_dummy_cols) > 0) {
    rlang::warn(c(
      "!" = glue::glue(
        "The following output columns already exist in `df`. They will be replaced.\n",
        glue::glue_collapse(existing_dummy_cols, sep = "\n")
      )
    ))
    # Remove them from df so bind_cols doesn't see duplicates and add new names that errors
    df <- dplyr::select(df, -dplyr::all_of(existing_dummy_cols))
  }

  #------ Compute

  results_list <- purrr::pmap(
    list(
      type = livestock,
      now_col = now_cols,
      ly_col = ly_cols,
      dummy_col = dummy_cols
    ),
    function(type, now_col, ly_col, dummy_col) {
      res <- dplyr::case_when(
        # any is missing, then missing
        is.na(df[[now_col]]) | is.na(df[[ly_col]]) ~ NA_real_,
        # if last year is 0 and this year is 0, then 0
        df[[ly_col]] == 0 & df[[now_col]] == 0 ~ 0,
        # if last year is 0 and this year is > 0, then 0 (not a decrease)
        df[[ly_col]] == 0 & df[[now_col]] > 0 ~ 0,
        (df[[ly_col]] - df[[now_col]]) / df[[ly_col]] >= threshold ~ 1,
        .default = 0
      )

      return(res)
    }
  )
  # Name the list elements with the dummy column names
  names(results_list) <- dummy_cols

  # Convert the list of vectors to a tibble (columns become the dummy variables)
  df_new <- as.data.frame(results_list)

  #------ Bind and Compute Composite

  # Bind the new columns to the original dataframe
  df <- dplyr::bind_cols(df, df_new)

  # Calculate the composite dummy
  df <- dplyr::mutate(
    df,
    !!composite_col := dplyr::case_when(
      rowSums(dplyr::pick(dplyr::all_of(dummy_cols)) == 1, na.rm = TRUE) >
        0 ~ 1,
      rowSums(!is.na(dplyr::pick(dplyr::all_of(dummy_cols)))) == 0 ~ NA_real_,
      .default = 0
    )
  )

  return(df)
}
