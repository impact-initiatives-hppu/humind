#' @title Add Multi-Sectoral Needs Index (MSNI) Score and Related Indicators
#'
#' @description This function calculates the MSNI score, determines if households are in need or acute need, counts the number of sectoral needs, and creates a sectoral needs profile.
#'
#' Prerequisite functions:
#'
#' * add_comp_edu.R
#' * add_comp_foodsec.R
#' * add_comp_health.R
#' * add_comp_prot.R
#' * add_comp_snfi.R
#' * add_comp_wash.R
#'
#' @param df A data frame containing sectoral composite scores and in-need indicators.
#' @param comp_foodsec_score Column name for the food security composite score.
#' @param comp_snfi_score Column name for the SNFI composite score.
#' @param comp_wash_score Column name for the WASH composite score.
#' @param comp_prot_score Column name for the protection composite score.
#' @param comp_health_score Column name for the health composite score.
#' @param comp_edu_score Column name for the education composite score.
#' @param comp_foodsec_in_need Column name for food security in need.
#' @param comp_snfi_in_need Column name for SNFI in need.
#' @param comp_wash_in_need Column name for WASH in need.
#' @param comp_prot_in_need Column name for protection in need.
#' @param comp_health_in_need Column name for health in need.
#' @param comp_edu_in_need Column name for education in need.
#'
#' @return A data frame with 5 new columns:
#'
#' * msni_score: The Multi-Sectoral Needs Index score.
#' * msni_in_need: Binary indicator for households in need.
#' * msni_in_acute_need: Binary indicator for households in acute need.
#' * sector_in_need_n: Number of sectoral needs identified.
#' * sector_needs_profile: Profile of sectoral needs identified (NA if no sectoral need is identified).
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
) {
  #------ Checks

  # All vars
  comp_scores <- c(
    comp_foodsec_score,
    comp_snfi_score,
    comp_wash_score,
    comp_prot_score,
    comp_health_score,
    comp_edu_score
  )
  comp_in_need <- c(
    comp_foodsec_in_need,
    comp_snfi_in_need,
    comp_wash_in_need,
    comp_prot_in_need,
    comp_health_in_need,
    comp_edu_in_need
  )
  comp_names <- c(
    "Food security",
    "SNFI",
    "WASH",
    "Protection",
    "Health",
    "Education"
  )

  # Check that score variables are in df, if they are not, throw a warning for the ones missing or stop if all are missing
  comp_scores_lgl <- comp_scores %in% colnames(df)
  comp_scores_nin <- comp_scores[!comp_scores_lgl]
  comp_scores <- comp_scores[comp_scores_lgl]
  # all missing
  if (!all(comp_scores_lgl)) {
    rlang::abort(paste(
      "There are none of the sectoral composites variables. Are you sure you specified the names correctly or you have run the necessary functions to add them?"
    ))
  }
  # Some missing
  if (any(!comp_scores_lgl)) {
    rlang::warn(paste(
      "The following variables are not in the data frame and the MSNI calculation will be run without them:",
      paste(comp_scores_nin, collapse = ", ")
    ))
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
    rlang::abort(paste(
      "There are none of the sectoral composites 'in need' variables. Are you sure you specified the names correctly or you have run the necessary functions to add them?"
    ))
  }
  # Some missing
  if (any(!comp_in_need_lgl)) {
    rlang::warn(paste(
      "The following variables are not in the data frame and the number of sectoral needs and the needs profile calculation will be run without them:",
      paste(comp_in_need_nin, collapse = ", ")
    ))
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
  df <- is_in_severe_need(
    df = df,
    score = "msni_score",
    new_colname = "msni_in_acute_need"
  )

  #------ Add number of sectoral needs

  # Sum vars across composites in need
  df <- sum_vars(
    df,
    comp_in_need,
    "sector_in_need_n",
    na_rm = TRUE,
    imputation = "none"
  )

  # If the sum is zero, NA the result
  df <- dplyr::mutate(
    df,
    sector_in_need_n = ifelse(
      !!rlang::sym("sector_in_need_n") == 0,
      NA,
      !!rlang::sym("sector_in_need_n")
    )
  )

  #------ Add needs profiles

  df_comp_in_need <- dplyr::select(df, dplyr::all_of(comp_in_need))

  df$sector_needs_profile <- purrr::pmap_chr(
    df_comp_in_need,
    function(...) {
      values <- c(...)
      labels <- comp_names[values == 1 & !is.na(values)]
      paste(labels, collapse = " - ")
    }
  )

  # NA if empty character string
  df <- dplyr::mutate(
    df,
    sector_needs_profile = ifelse(
      !!rlang::sym("sector_needs_profile") == "",
      NA,
      !!rlang::sym("sector_needs_profile")
    )
  )

  #------ Return

  return(df)
}
