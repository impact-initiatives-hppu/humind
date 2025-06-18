#' @title Add Category of Shelter damage (Optional SNFI dimension)
#'
#' @description This function categorizes No damage, damaged, partial collapse / partial destruction based on provided criteria.
#'
#' @param df A data frame containing shelter damage arrangement.
#' @param snfi_shelter_damage The name of the column  containing shelter damage status.
#' @param snfi_shelter_damage_none The value indicating no damage.
#' @param snfi_shelter_damage_damaged Values indicating minor damage to roof and other damages.
#' @param snfi_shelter_damage_part The value indicating major damage to roof with risk of collapse.
#' @param snfi_shelter_damage_total The value indicating total collapse or destruction.
#' @param snfi_shelter_damage_undefined Values indicating undefined or unknown status.
#'
#' @return A data frame with an additional column:
#'
#' * snfi_shelter_damage_cat: Categorized shelter damages: "none", "damaged", "part", "total", or "undefined".
#'
#' @export
#'
add_shelter_damage_cat <- function(
    df,
    snfi_shelter_damage = "snfi_shelter_damage",
    snfi_shelter_damage_none = "none",
    snfi_shelter_damage_damaged = c("minor", "damage_windows_doors", "damage_floors", "damage_walls"),
    snfi_shelter_damage_part = "major",
    snfi_shelter_damage_total = "total_collapse",
    snfi_shelter_damage_undefined = c("dnk", "pnta", "other")

) {

  #------ Checks

  # Check if the variable is in the data frame
  if_not_in_stop(df, snfi_shelter_damage, "df")

  # Check if values are in set
  are_values_in_set(df, snfi_shelter_damage, c(snfi_shelter_damage_none, snfi_shelter_damage_damaged, snfi_shelter_damage_part, snfi_shelter_damage_total, snfi_shelter_damage_undefined))

  #------ Recode

  df <- dplyr::mutate(
    df,
    snfi_shelter_damage_cat = dplyr::case_when(
      .data[[snfi_shelter_damage]] == snfi_shelter_damage_none ~ "none",
      .data[[snfi_shelter_damage]] %in% snfi_shelter_damage_damaged ~ "damaged",
      .data[[snfi_shelter_damage]] == snfi_shelter_damage_part ~ "part",
      .data[[snfi_shelter_damage]] == snfi_shelter_damage_total ~ "total",
      .data[[snfi_shelter_damage]] %in% snfi_shelter_damage_undefined ~ "undefined",
      .default = NA_character_
    )
  )

  return(df)

}
