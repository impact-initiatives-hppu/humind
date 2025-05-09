#' @title Add Functional Domestic Space Tasks Categories
#'
#' @description This function adds categories for functional domestic space tasks based on various input parameters.
#' It processes cooking, sleeping, storing, personal hygiene, and lighting tasks, creating new columns with standardized categories and a summary of tasks that cannot be performed.
#'
#' @param df A data frame containing the input columns
#' @param fds_cooking Column name for cooking tasks
#' @param fds_cooking_cannot Value for cannot perform cooking tasks
#' @param fds_cooking_can_issues Value for can perform cooking tasks but with issues
#' @param fds_cooking_can_no_issues Value for can perform cooking tasks without issues
#' @param fds_cooking_no_need Value for no need to perform cooking tasks
#' @param fds_cooking_undefined Vector of undefined responses for cooking tasks
#' @param fds_sleeping Column name for sleeping tasks
#' @param fds_sleeping_cannot Value for cannot perform sleeping tasks
#' @param fds_sleeping_can_issues Value for can perform sleeping tasks but with issues
#' @param fds_sleeping_can_no_issues Value for can perform sleeping tasks without issues
#' @param fds_sleeping_undefined Vector of undefined responses for sleeping tasks
#' @param fds_storing Column name for storing tasks
#' @param fds_storing_cannot Value for cannot perform storing tasks
#' @param fds_storing_can_issues Value for can perform storing tasks but with issues
#' @param fds_storing_can_no_issues Value for can perform storing tasks without issues
#' @param fds_storing_undefined Vector of undefined responses for storing tasks
#' @param fds_personal_hygiene Column name for personal hygiene tasks
#' @param fds_personal_hygiene_cannot Value for cannot perform personal hygiene tasks
#' @param fds_personal_hygiene_can_issues Value for can perform personal hygiene tasks but with issues
#' @param fds_personal_hygiene_can_no_issues Value for can perform personal hygiene tasks without issues
#' @param fds_personal_hygiene_undefined Vector of undefined responses for personal hygiene tasks
#' @param lighting_source Column name for lighting source
#' @param lighting_source_none Value for no lighting source
#' @param lighting_source_undefined Vector of undefined responses for lighting source
#'
#' @return A data frame with additional columns:
#' 
#' * snfi_fds_cooking: Standardized categories for cooking tasks
#' * snfi_fds_sleeping: Standardized categories for sleeping tasks
#' * snfi_fds_storing: Standardized categories for storing tasks
#' * snfi_fds_personal_hygiene: Standardized categories for personal hygiene tasks
#' * energy_lighting_source: Standardized categories for lighting source
#' * snfi_fds_cannot_n: Number of tasks that cannot be performed
#' * snfi_fds_cannot_cat: Categorized number of tasks that cannot be performed
#'
#' @export
#'
add_fds_cannot_cat <- function(
    df,
    fds_cooking = "snfi_fds_cooking",
    fds_cooking_cannot = "no_cannot",
    fds_cooking_can_issues = "yes_issues",
    fds_cooking_can_no_issues = "yes_no_issues",
    fds_cooking_no_need = "no_no_need",
    fds_cooking_undefined = c("pnta", "dnk"),
    fds_sleeping = "snfi_fds_sleeping",
    fds_sleeping_cannot = "no",
    fds_sleeping_can = "yes",
    fds_sleeping_undefined = c("pnta"),
    fds_storing = "snfi_fds_storing",
    fds_storing_cannot = "no_cannot",
    fds_storing_can_issues = "yes_issues",
    fds_storing_can_no_issues = "yes_no_issues",
    fds_storing_undefined = c("pnta", "dnk"),
    fds_personal_hygiene = "snfi_fds_personal_hygiene",
    fds_personal_hygiene_cannot = "no_cannot",
    fds_personal_hygiene_can_issues = "yes_issues",
    fds_personal_hygiene_can_no_issues = "yes_no_issues",
    fds_personal_hygiene_undefined = c("pnta", "dnk"),
    lighting_source = "energy_lighting_source",
    lighting_source_none = "none",
    lighting_source_undefined = c("pnta", "dnk")
){

  #------ Checks

  # Check if all columns are present
  if_not_in_stop(df, c(fds_cooking, fds_sleeping, fds_storing, fds_personal_hygiene, lighting_source), "df")

  # Check if values are in set
  are_values_in_set(df, fds_cooking, c(fds_cooking_cannot, fds_cooking_can_issues, fds_cooking_can_no_issues, fds_cooking_no_need, fds_cooking_undefined))
  are_values_in_set(df, fds_sleeping, c(fds_sleeping_cannot, fds_sleeping_can_issues, fds_sleeping_can_no_issues, fds_sleeping_undefined))
  are_values_in_set(df, fds_storing, c(fds_storing_cannot, fds_storing_can_issues, fds_storing_can_no_issues, fds_storing_undefined))
  are_values_in_set(df, fds_personal_hygiene, c(fds_personal_hygiene_cannot, fds_personal_hygiene_can_issues, fds_personal_hygiene_can_no_issues, fds_personal_hygiene_undefined))

  # Checks if all parameters that are not "undefined" are of length 1
  if (length(fds_cooking_cannot) != 1) rlang::abort("fds_cooking_cannot must be of length 1")
  if (length(fds_cooking_can_issues) != 1) rlang::abort("fds_cooking_can_issues must be of length 1")
  if (length(fds_cooking_can_no_issues) != 1) rlang::abort("fds_cooking_can_no_issues must be of length 1")
  if (length(fds_cooking_no_need) != 1) rlang::abort("fds_cooking_no_need must be of length 1")
  if (length(fds_sleeping_cannot) != 1) rlang::abort("fds_sleeping_cannot must be of length 1")
  if (length(fds_sleeping_can_issues) != 1) rlang::abort("fds_sleeping_can_issues must be of length 1")
  if (length(fds_sleeping_can_no_issues) != 1) rlang::abort("fds_sleeping_can_no_issues must be of length 1")
  if (length(fds_storing_cannot) != 1) rlang::abort("fds_storing_cannot must be of length 1")
  if (length(fds_storing_can_issues) != 1) rlang::abort("fds_storing_can_issues must be of length 1")
  if (length(fds_storing_can_no_issues) != 1) rlang::abort("fds_storing_can_no_issues must be of length 1")
  if (length(fds_personal_hygiene_cannot) != 1) rlang::abort("fds_personal_hygiene_cannot must be of length 1")
  if (length(fds_personal_hygiene_can_issues) != 1) rlang::abort("fds_personal_hygiene_can_issues must be of length 1")
  if (length(fds_personal_hygiene_can_no_issues) != 1) rlang::abort("fds_personal_hygiene_can_no_issues must be of length 1")
  if (length(lighting_source_none) != 1) rlang::abort("lighting_source_none must be of length 1")

  #----- Prepare dummy
  df <- dplyr::mutate(
      df,
      snfi_fds_cooking = dplyr::case_when(
        !!rlang::sym(fds_cooking) == fds_cooking_cannot ~ "no_cannot",
        !!rlang::sym(fds_cooking) == fds_cooking_can_issues ~ "yes_issues",
        !!rlang::sym(fds_cooking) == fds_cooking_can_no_issues ~ "yes_no_issues",
        !!rlang::sym(fds_cooking) == fds_cooking_no_need ~ "no_no_need",
        !!rlang::sym(fds_cooking) %in% fds_cooking_undefined ~ "undefined",
        .default = NA_character_
      ),
      snfi_fds_sleeping = dplyr::case_when(
        !!rlang::sym(fds_sleeping) == fds_sleeping_cannot ~ "no",
        !!rlang::sym(fds_sleeping) == fds_sleeping_can ~ "yes",
        !!rlang::sym(fds_sleeping) %in% fds_sleeping_undefined ~ "undefined",
        .default = NA_character_
      ),
      snfi_fds_storing = dplyr::case_when(
        !!rlang::sym(fds_storing) == fds_storing_cannot ~ "no_cannot",
        !!rlang::sym(fds_storing) == fds_storing_can_issues ~ "yes_issues",
        !!rlang::sym(fds_storing) == fds_storing_can_no_issues ~ "yes_no_issues",
        !!rlang::sym(fds_storing) %in% fds_storing_undefined ~ "undefined",
        .default = NA_character_
      ),
      snfi_fds_personal_hygiene = dplyr::case_when(
        !!rlang::sym(fds_personal_hygiene) == fds_personal_hygiene_cannot ~ "no_cannot",
        !!rlang::sym(fds_personal_hygiene) == fds_personal_hygiene_can_issues ~ "yes_issues",
        !!rlang::sym(fds_personal_hygiene) == fds_personal_hygiene_can_no_issues ~ "yes_no_issues",
        !!rlang::sym(fds_personal_hygiene) %in% fds_personal_hygiene_undefined ~ "undefined",
        .default = NA_character_
      ),
      energy_lighting_source = dplyr::case_when(
        is.na(!!rlang::sym(lighting_source)) ~ NA_character_,
        !!rlang::sym(lighting_source) %in% lighting_source_undefined ~ "undefined",
        !!rlang::sym(lighting_source) == lighting_source_none ~ "none",
        .default = !!rlang::sym(lighting_source)
      )
    )

  #----- Sum across cols if "no_cannot"
  df <- dplyr::mutate(
    df,
    dplyr::across(
      c("snfi_fds_cooking", "snfi_fds_sleeping", "snfi_fds_storing", "snfi_fds_personal_hygiene"),
      \(x) dplyr::case_when(
        x %in% c("no_cannot", "no") ~ 1,
        x %in% c("yes_issues", "yes_no_issues", "no_no_need", "yes") ~ 0,
        .default = NA_real_
      ),
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
    vars = c("snfi_fds_cooking_d", "snfi_fds_sleeping_d", "snfi_fds_storing_d", "snfi_fds_personal_hygiene_d", "energy_lighting_source_d"),
    na_rm = FALSE,
    imputation = "none"
  )

  #------ Recode to categories cannot perform 0 task, 1task, 2-3 tasks, 4 to 5 tasks
  df <- dplyr::mutate(
    df,
    snfi_fds_cannot_cat = dplyr::case_when(
      snfi_fds_cannot_n == 0 ~ "none",
      snfi_fds_cannot_n == 1 ~ "1_task",
      snfi_fds_cannot_n %in% 2:3 ~ "2_to_3_tasks",
      snfi_fds_cannot_n %in% 4:5 ~ "4_to_5_tasks",
      .default = NA_character_
    )
    )

  return(df)
}
