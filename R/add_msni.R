#' Add MSNI - add score and dummy for in need
#'
#' The output is a data frame with 5 new columns. First the MSNI-related variables: `msni_score`, `msni_in_need`, and `msni_in_acute_need`. The two latter are used for metrics 1 and 2. Second, the number of sectoral needs `sector_in_need_n` and the sectoral needs profile `sector_needs_profile`. These two are used for metric 3 and 4.
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
  comp_edu_score = "comp_edu_score",
  comp_foodsec_in_need = "comp_foodsec_in_need",
  comp_snfi_in_need = "comp_snfi_in_need",
  comp_wash_in_need = "comp_wash_in_need",
  comp_prot_in_need = "comp_prot_in_need",
  comp_health_in_need = "comp_health_in_need",
  comp_edu_in_need = "comp_edu_in_need"
  ){

  #------ Checks

  # All vars
  comp_scores <- c(comp_foodsec_score, comp_snfi_score, comp_wash_score, comp_prot_score, comp_health_score, comp_edu_score)
  comp_in_need <- c(comp_foodsec_in_need, comp_snfi_in_need, comp_wash_in_need, comp_prot_in_need, comp_health_in_need, comp_edu_in_need)
  comp_names <- c("Food security", "SNFI", "WASH", "Protection", "Health", "Education")

  # Check that score variables are in df, if they are not, throw a warning for the ones missing or stop if all are missing
  comp_scores_lgl <- comp_scores %in% colnames(df)
  comp_scores_nin <- comp_scores[!comp_scores_lgl]
  comp_scores <- comp_scores[comp_scores_lgl]
  # all missing
  if (!all(comp_scores_lgl)) {
    rlang::abort(paste("There are none of the sectoral composites variables. Are you sure you specified the names correctly or you have run the necessary functions to add them?"))
  }
  # Some missing
  if (any(!comp_scores_lgl)) {
    rlang::warn(paste("The following variables are not in the data frame and the MSNI calculation will be run without them:", paste(comp_scores_nin, collapse = ", ")))
  }

  # Check that all values are in set 1:5
  are_values_in_set(df, comp_scores, 1:5)


  # Check that the dummy variables for in need are in df
  comp_in_need_lgl <- comp_in_need %in% colnames(df)
  comp_in_need_nin <- comp_in_need[!comp_in_need_lgl]
  comp_in_need <- comp_in_need[comp_in_need_lgl]
  comp_names <- comp_names[comp_in_need_lgl]
  # all missing
  if (!all(comp_in_need_lgl)) {
    rlang::abort(paste("There are none of the sectoral composites 'in need' variables. Are you sure you specified the names correctly or you have run the necessary functions to add them?"))
  }
  # Some missing
  if (any(!comp_in_need_lgl)) {
    rlang::warn(paste("The following variables are not in the data frame and the number of sectoral needs and the needs profile calculation will be run without them:", paste(comp_in_need_nin, collapse = ", ")))
  }

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

  #------ Add number of sectoral needs

  df <- sum_vars(
    df,
    comp_in_need,
    "sector_in_need_n",
    na_rm = TRUE,
    imputation = "none")

  #------ Add needs profiles

  df_comp_in_need <-  dplyr::select(df, dplyr::all_of(comp_in_need))

  df$sector_needs_profile <- purrr::pmap_chr(
    df_comp_in_need,
    function(...){
      values <- c(...)
      labels <- comp_names[values == 1 & !is.na(values)]
      paste(labels, collapse = " - ")
    })


  #------ Return

  return(df)

}
