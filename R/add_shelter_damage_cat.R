#' @title Add Category of Shelter damage (Optional SNFI dimension)
#'
#' @description This function categorizes the shelter damage category based on provided criteria.
#'
#' @param df Data frame containing the survey data.
#' @param sep Separator for the binary columns, default is "/".
#' @param snfi_shelter_damage Column name
#' @param none answer option
#' @param minor answer option
#' @param major answer option
#' @param damage_windows_doors answer option
#' @param damage_floors answer option
#' @param damage_walls answer option
#' @param total_collapse answer option
#' @param other answer option
#' @param dnk answer option
#' @param pnta answer option
#'
#' @return A data frame with an additional column:
#'
#' * snfi_shelter_damage_cat: Categorized shelter damages: "No damage", "Damaged", "Partial collapse or destruction", "Total collapse or destruction", or "Undefined".
#'
#' @export
#'
add_shelter_damage_cat <- function(
  df,
  sep = "/",
  snfi_shelter_damage = "snfi_shelter_damage",
  none = "none",
  minor = "minor",
  major = "major",
  damage_windows_doors = "damage_windows_doors",
  damage_floors = "damage_floors",
  damage_walls = "damage_walls",
  total_collapse = "total_collapse",
  other = "other",
  dnk = "dnk",
  pnta = "pnta"
) {
  # Option answers list
  user_answer_options <- c(
    none = none,
    minor = minor,
    major = major,
    damage_windows_doors = damage_windows_doors,
    damage_floors = damage_floors,
    damage_walls = damage_walls,
    total_collapse = total_collapse,
    other = other,
    dnk = dnk,
    pnta = pnta
  )

  # build the raw column names
  ssd_col_names <- stringr::str_glue(
    "{snfi_shelter_damage}{sep}{user_answer_options}"
  )

  # sanity checks
  if_not_in_stop(df, ssd_col_names, "df")
  are_values_in_set(df, ssd_col_names, c(0, 1))

  #------ Recode

  # Define answer sets for each category (column suffixes)
  snfi_shelter_damage_none <- none
  snfi_shelter_damage_damaged <- c(
    minor,
    damage_windows_doors,
    damage_floors,
    damage_walls
  )
  snfi_shelter_damage_partial <- major
  snfi_shelter_damage_total <- total_collapse
  # Undifined categories
  snfi_shelter_damage_undefined <- c(dnk, pnta, other)

  # Build full column names for each category
  col_none <- stringr::str_glue(
    "{snfi_shelter_damage}{sep}{snfi_shelter_damage_none}"
  )
  col_damaged <- stringr::str_glue(
    "{snfi_shelter_damage}{sep}{snfi_shelter_damage_damaged}"
  )
  col_part <- stringr::str_glue(
    "{snfi_shelter_damage}{sep}{snfi_shelter_damage_partial}"
  )
  col_total <- stringr::str_glue(
    "{snfi_shelter_damage}{sep}{snfi_shelter_damage_total}"
  )
  col_undefined <- stringr::str_glue(
    "{snfi_shelter_damage}{sep}{snfi_shelter_damage_undefined}"
  )

  # Constraint check: cannot select "no damage" or "don't know" or "prefer not to answer" with any other option
  # Build a logical vector for each constraint column

  dnk_col <- stringr::str_glue("{snfi_shelter_damage}{sep}{dnk}")
  pnta_col <- stringr::str_glue("{snfi_shelter_damage}{sep}{pnta}")
  # All damage columns (excluding none, dnk, pnta)
  damage_cols <- setdiff(ssd_col_names, c(col_none, dnk_col, pnta_col))

  # Logical matrix for constraint violation (base R, not dplyr::across)
  none_selected <- rowSums(df[, col_none, drop = FALSE] == 1, na.rm = TRUE) > 0
  dnk_selected <- rowSums(df[, dnk_col, drop = FALSE] == 1, na.rm = TRUE) > 0
  pnta_selected <- rowSums(df[, pnta_col, drop = FALSE] == 1, na.rm = TRUE) > 0
  damage_selected <- rowSums(
    df[, damage_cols, drop = FALSE] == 1,
    na.rm = TRUE
  ) >
    0

  violation <- (none_selected & damage_selected) |
    (dnk_selected & damage_selected) |
    (pnta_selected & damage_selected)
  n_viol <- sum(violation, na.rm = TRUE)
  if (n_viol > 0) {
    viol_rows <- which(violation)
    percent <- round(100 * n_viol / nrow(df), 1)
    warning(sprintf(
      "%d row(s) (%.1f%%) violate the constraint: cannot select 'no damage', 'don't know', or 'prefer not to answer' with any other option. Row indices: %s",
      n_viol,
      percent,
      paste(viol_rows, collapse = ", ")
    ))
  }

  # Categorisation
  # Severity order: from worst to best
  df <- dplyr::mutate(
    df,
    snfi_shelter_damage_cat = dplyr::case_when(
      rowSums(dplyr::across(dplyr::all_of(col_total)) == 1) > 0 ~
        "Total collapse or destruction",
      rowSums(dplyr::across(dplyr::all_of(col_part)) == 1) > 0 ~
        "Partial collapse or destruction",
      rowSums(dplyr::across(dplyr::all_of(col_damaged)) == 1) > 0 ~ "Damaged",
      rowSums(dplyr::across(dplyr::all_of(col_none)) == 1) > 0 ~ "No damage",
      rowSums(dplyr::across(dplyr::all_of(col_undefined)) == 1) > 0 ~
        "Undefined",
      TRUE ~ NA_character_
    )
  )

  return(df)
}
