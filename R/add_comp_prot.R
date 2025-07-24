#' Add overall Protection composite score and need flags
#'
#' Assumes that per‑dimension severity scores have already been computed and added to `df` by earlier functions: [add_prot_score_movement()], [add_prot_score_practices()], and [add_prot_score_rights()].
#' This function performs only **Step 4** of the 2025 Protection Composite workflow: it takes the maximum of those three existing columns to create `comp_prot_score`, then generates binary “in need” indicators.
#'
#' @param df A `data.frame` or `tibble` containing numeric columns:
#' * `comp_prot_score_movement` – severity for movement dimension
#' * `comp_prot_score_practices` – severity for practices dimension
#' * `comp_prot_score_rights` – severity for rights & services dimension
#'
#' If any of these three columns are missing, the function will abort, reminding you to run the corresponding prep functions first.
#'
#' @return The input `df`, with three new columns:
#' * `comp_prot_score` – overall protection severity (maximum of the three dimensions)
#' * `comp_prot_in_need` – binary (0/1): 1 if `comp_prot_score >= 3`, else 0
#' * `comp_prot_in_acute_need` – binary (0/1): 1 if `comp_prot_score >= 4`, else 0
#'
#' @details
#' - **Column checks** via [purrr::iwalk()] ensure the three dimension scores exist.
#' - **Computation** uses [pmax()] (with `na.rm = FALSE`)
#' - **Thresholds** (3 for “in need”, 4 for “acute need”) are currently hard‑coded.
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
    # TODO: Handle NA values
    comp_prot_score = pmax(
      .data[["comp_prot_score_movement"]],
      .data[["comp_prot_score_practices"]],
      .data[["comp_prot_score_rights"]],
    ),
    comp_prot_in_need = as.numeric(.data[["comp_prot_score"]] >= 3),
    comp_prot_in_acute_need = as.numeric(.data[["comp_prot_score"]] >= 4)
  )
}
