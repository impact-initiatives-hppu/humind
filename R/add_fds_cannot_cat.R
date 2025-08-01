#' @title Add Functional Domestic Space Tasks Categories
#'
#' @description This function adds categories for functional domestic space tasks based on various input parameters.
#' It processes cooking, sleeping, storing, and lighting tasks, creating new columns with standardized categories and a summary of tasks that cannot be performed.
#'
#' @param df A data frame containing the input columns
#' @param fds_cooking Column name for cooking tasks
#' @param fds_cooking_cannot Value for facing issues when cooking
#' @param fds_cooking_can Value for can perform cooking tasks without issues
#' @param fds_cooking_no_need Value for no need to perform cooking tasks
#' @param fds_cooking_undefined Vector of undefined responses for cooking tasks
#' @param fds_sleeping Column name for sleeping tasks
#' @param fds_sleeping_cannot Value for cannot perform sleeping tasks
#' @param fds_sleeping_can Value for can perform sleeping tasks
#' @param fds_sleeping_undefined Vector of undefined responses for sleeping tasks
#' @param fds_storing Column name for storing tasks
#' @param fds_storing_cannot Value for cannot perform storing tasks
#' @param fds_storing_can Value for can perform storing tasks
#' @param fds_storing_undefined Vector of undefined responses for storing tasks
#' @param lighting_source Column name for lighting source
#' @param lighting_source_none Value for no lighting source
#' @param lighting_source_undefined Vector of undefined responses for lighting source
#'
#' @return A data frame with additional columns:
#'
#' * snfi_fds_cooking: Standardized categories for cooking tasks
#' * snfi_fds_sleeping: Standardized categories for sleeping tasks
#' * snfi_fds_storing: Standardized categories for storing tasks
#' * energy_lighting_source: Standardized categories for lighting source
#' * snfi_fds_cannot_n: Number of tasks that cannot be performed
#' * snfi_fds_cannot_cat: Categorized number of tasks that cannot be performed
#'
#' @export
#'
add_fds_cannot_cat <- function(
  df,
  fds_cooking = "snfi_fds_cooking",
  fds_cooking_can = "no",
  fds_cooking_cannot = "yes",
  fds_cooking_no_need = "no_need",
  fds_cooking_undefined = "pnta",
  fds_sleeping = "snfi_fds_sleeping",
  fds_sleeping_can = "yes",
  fds_sleeping_cannot = "no",
  fds_sleeping_undefined = "pnta",
  fds_storing = "snfi_fds_storing",
  fds_storing_cannot = "no",
  fds_storing_can = c("yes_issues", "yes_no_issues"),
  fds_storing_undefined = "pnta",
  lighting_source = "energy_lighting_source",
  lighting_source_none = "none",
  lighting_source_undefined = c("pnta", "dnk")
) {
  #------ Checks

  # Check if all columns are present
  if_not_in_stop(
    df,
    c(fds_cooking, fds_sleeping, fds_storing, lighting_source),
    "df"
  )

  # Check if values are in set
  are_values_in_set(
    df,
    fds_cooking,
    c(
      fds_cooking_can,
      fds_cooking_cannot,
      fds_cooking_no_need,
      fds_cooking_undefined
    )
  )
  are_values_in_set(
    df,
    fds_sleeping,
    c(fds_sleeping_cannot, fds_sleeping_can, fds_sleeping_undefined)
  )

  are_values_in_set(
    df,
    fds_storing,
    c(fds_storing_cannot, fds_storing_can, fds_storing_undefined)
  )

  # Checks if all parameters that are not "undefined" are of length 1
  if (length(fds_cooking_cannot) != 1) {
    rlang::abort("fds_cooking_cannot must be of length 1")
  }
  if (length(fds_cooking_can) != 1) {
    rlang::abort("fds_cooking_can must be of length 1")
  }
  if (length(fds_cooking_no_need) != 1) {
    rlang::abort("fds_cooking_no_need must be of length 1")
  }
  if (length(fds_sleeping_cannot) != 1) {
    rlang::abort("fds_sleeping_cannot must be of length 1")
  }
  if (length(fds_sleeping_can) != 1) {
    rlang::abort("fds_sleeping_can must be of length 1")
  }
  if (length(lighting_source_none) != 1) {
    rlang::abort("lighting_source_none must be of length 1")
  }

  #----- Prepare dummy
  df <- dplyr::mutate(
    df,
    snfi_fds_cooking = dplyr::case_when(
      !!rlang::sym(fds_cooking) == fds_cooking_can ~ "yes",
      !!rlang::sym(fds_cooking) == fds_cooking_cannot ~ "no_cannot",
      !!rlang::sym(fds_cooking) == fds_cooking_no_need ~ "no_no_need",
      !!rlang::sym(fds_cooking) == fds_cooking_undefined ~ "undefined",
      .default = NA_character_
    ),
    snfi_fds_sleeping = dplyr::case_when(
      !!rlang::sym(fds_sleeping) == fds_sleeping_cannot ~ "no_cannot",
      !!rlang::sym(fds_sleeping) == fds_sleeping_can ~ "yes",
      !!rlang::sym(fds_sleeping) == fds_sleeping_undefined ~ "undefined",
      .default = NA_character_
    ),
    snfi_fds_storing = dplyr::case_when(
      !!rlang::sym(fds_storing) == fds_storing_cannot ~ "no_cannot",
      !!rlang::sym(fds_storing) %in% fds_storing_can ~ "yes",
      !!rlang::sym(fds_storing) == fds_storing_undefined ~ "undefined",
      .default = NA_character_
    ),
    energy_lighting_source = dplyr::case_when(
      is.na(!!rlang::sym(lighting_source)) ~ NA_character_,
      !!rlang::sym(lighting_source) %in% lighting_source_undefined ~
        "undefined",
      !!rlang::sym(lighting_source) == lighting_source_none ~ "none",
      .default = !!rlang::sym(lighting_source)
    )
  )

  #----- Sum across cols if "no_cannot"
  df <- dplyr::mutate(
    df,
    dplyr::across(
      c("snfi_fds_cooking", "snfi_fds_sleeping", "snfi_fds_storing"),
      \(x) {
        dplyr::case_when(
          x == "no_cannot" ~ 1,
          x %in% c("yes", "no_no_need") ~ 0,
          .default = NA_real_
        )
      },
      .names = "{.col}_d"
    )
  )

  # Add binary for lighting
  df <- dplyr::mutate(
    df,
    energy_lighting_source_d = dplyr::case_when(
      energy_lighting_source == "none" ~ 1,
      energy_lighting_source == "undefined" ~ NA_real_,
      is.na(energy_lighting_source) ~ NA_real_,
      .default = 0
    )
  )

  df <- sum_vars(
    df,
    new_colname = "snfi_fds_cannot_n",
    vars = c(
      "snfi_fds_cooking_d",
      "snfi_fds_sleeping_d",
      "snfi_fds_storing_d",
      "energy_lighting_source_d"
    ),
    na_rm = FALSE,
    imputation = "none"
  )

  #------ Recode to categories cannot perform 0 task, 1task, 2-3 tasks, 4 tasks
  df <- dplyr::mutate(
    df,
    snfi_fds_cannot_cat = dplyr::case_when(
      snfi_fds_cannot_n == 0 ~ "none",
      snfi_fds_cannot_n == 1 ~ "1_task",
      snfi_fds_cannot_n %in% 2:3 ~ "2_to_3_tasks",
      snfi_fds_cannot_n == 4 ~ "4_tasks",
      .default = NA_character_
    )
  )

  return(df)
}
