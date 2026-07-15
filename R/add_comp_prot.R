#' @title Add Protection Sectoral Composite Score and Need Indicators
#'
#' @description
#' This function calculates a protection sectoral composite score based on the
#' movement, practices, and rights & services dimension scores. It takes the
#' maximum of the three dimension scores as the overall protection severity,
#' and determines if a household is in need or in severe need of protection
#' assistance based on the calculated score.
#'
#' Prerequisite functions:
#'
#' * [add_prot_score_movement()]
#' * [add_prot_score_practices()]
#' * [add_prot_score_rights()]
#'
#'
#' @param df A data frame containing the movement, practices, and rights & services dimension scores.
#'
#' @return A data frame with additional columns:
#'
#' * comp_prot_score: Protection composite score (maximum of the three dimension scores)
#' * comp_prot_in_need: Binary indicator for being in need of protection assistance
#' * comp_prot_in_severe_need: Binary indicator for being in severe need of protection assistance
#'
#' @importFrom purrr iwalk
#' @importFrom cli cli_abort
#' @importFrom dplyr mutate
#' @export
add_comp_prot <- function(df) {
  composite_func_mapping <- list(
    "comp_prot_score_movement" = "add_prot_score_movement",
    "comp_prot_score_practices" = "add_prot_score_practices",
    "comp_prot_score_rights" = "add_prot_score_rights"
  )

  purrr::iwalk(
    composite_func_mapping,
    ~ {
      col <- .y
      func <- .x

      if (!col %in% names(df)) {
        cli::cli_abort(
          "Column {.field {col}} does not exist; make sure you've run {.fun {func}} first."
        )
      }
    }
  )

  dplyr::mutate(
    df,
    comp_prot_score = pmax(
      .data[["comp_prot_score_movement"]],
      .data[["comp_prot_score_practices"]],
      .data[["comp_prot_score_rights"]],
      na.rm = TRUE
    ),
    comp_prot_in_need = as.numeric(.data[["comp_prot_score"]] >= 3),
    comp_prot_in_severe_need = as.numeric(.data[["comp_prot_score"]] >= 4)
  )
}
