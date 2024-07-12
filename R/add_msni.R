#' Add MSNI - add score and dummy for in need
#'
#' The output is a data frame with three new columns: `msni_score`, "msni_in_need", and "msni_in_acute_need".`
#'
#' @param df A data frame.
#' @param comp_foodsec_score Column name for the food security composite score.
#' @param comp_snfi_score Column name for the SNFI composite score.
#' @param comp_wash_score Column name for the WASH composite score.
#' @param comp_prot_score Column name for the protection composite score.
#' @param comp_health_score Column name for the health composite score.
#' @param comp_edu_score Column name for the education composite score.
#'
#' @export
add_msni <- function(
  df,
  comp_foodsec_score = "comp_foodsec_score",
  comp_snfi_score = "comp_snfi_score",
  comp_wash_score = "comp_wash_score",
  comp_prot_score = "comp_prot_score",
  comp_health_score = "comp_health_score",
  comp_edu_score = "comp_edu_score"){

  #------ Checks

  # All vars
  comp_scores <- c(comp_foodsec_score, comp_snfi_score, comp_wash_score, comp_prot_score, comp_health_score, comp_edu_score)

  # Check that variables are in df, if they are not, throw a warning for the ones missing
  comp_in_df <- comp_scores %in% df
  if (any(!comp_in_df)) {
    rlang::warn(paste("The following variables are not in the data frame and the calculation will be run without them:", paste(comp_scores[!comp_in_df], collapse = ", ")))
  }

  # Keep only existing ones
  comp_scores <- comp_scores[comp_in_df]

  # Check that all values are in set 1:5
  are_values_in_set(df, comp_scores, 1:5)

  #------ Take the maximum

  df <- dplyr::mutate(
    df,
    msni_score = pmax(
      !!!rlang::syms(comp_scores),
      na.rm = TRUE
    )
  )

  #------ Create dummy "in need"

  # Is in need?
  df <- is_in_need(
    df = df,
    score = "msni_score",
    new_colname = "msni_in_need"
  )

  # Is in acute need?
  df <- is_in_acute_need(
    df = df,
    score = "msni_score",
    new_colname = "msni_in_acute_need"
  )

  return(df)

}
