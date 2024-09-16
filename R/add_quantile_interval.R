#' Add a income group intervals
#'
#' [add_quantile_interval()] function calculates weighted income quantiles and classifies households according to these.
#'
#' @param df A dataframe.
#' @param vars The variable or variables with income integer values.
#' @param cut_offs The cut-offs for computaton of quantiles. The default corresponds to the quantiles of the distribution, based on the weighted median.
#' @param weight The sampling weights.
#' @param group Can be used to compute the quanitles for the sampled sub-groups.
#'
#' @export

add_quantile_interval <- function(
    df,
    vars,
    cut_offs = c(0, 0.2, 0.4, 0.6, 0.8, 1),
    weight = NULL,
    group = NULL
){

  #------ Checks

  # Check if the variable are present
  if_not_in_stop(df, vars, "df")

  # Check if the variables are numeric
  are_cols_numeric(df, vars)

  # Check if "weight" is present if not NULL
  if (!is.null(weight)) if_not_in_stop(df, weight, "df")

  # Check if group is NULL if group is there
  if (!is.null(group)) if_not_in_stop(df, group, "df")

  # Warn that vars_qtl will be replaced if they exist
  vars_names <- paste0(vars, "_qtl")
  if (any(vars_names %in% names(df))) {
    rlang::warn(
      paste0(
        "The following variables already exist and will be replaced:",
        paste0(vars_names[vars_names %in% names(df)], collapse = ", "))
    )
  }


  #------ Calculate quantile intervals

  # Iterate the weighted quantile functions over all vars
  qtl <- purrr::map(
    dplyr::select(df, dplyr::all_of(vars)),
    \(x) Hmisc::wtd.quantile(x, weights = weight, probs = cut_offs, type = "quantile")
  )

  # Iterate to get neat vector of quantile labels for all vars
  qtl_labs <- purrr::imap(
    qtl,
    \(x, idx) paste(names(x)[-length(names(x))], names(x)[-1], sep = "-")
  )

  # Use the num cat function across columns
  l_df_qtl <- purrr::map(
    vars,
    \(x) {

      # Is x NA only?
      is_x_na <- all(is.na(df[[x]]))

      if (is_x_na) {

        int <- dplyr::mutate(
          df,
          "{x}_qtl" := NA_character_
        )

      } else {

        int <- num_cat(
          df = df,
          num_col = x,
          breaks =  qtl[[x]],
          labels = qtl_labs[[x]],
          int_undefined = c(-999, 999),
          char_undefined = "Unknown",
          new_colname = paste0(x, "_qtl"),
          plus_last = FALSE)
  
      }

      int <- dplyr::select(int, !!rlang::sym(paste0(x, "_qtl")))

      return(int)

    }
  )

  # List cbind
  df_qtl <- purrr::list_cbind(l_df_qtl)

  #  Remove vars from df that are in df_qtl
  df <- impactR.utils::df_diff(df, df_qtl)

  # Cbind to df
  df <- dplyr::bind_cols(df, df_qtl)

  return(df)

}
