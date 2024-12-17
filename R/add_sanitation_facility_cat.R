#' @title Sanitation Facility Classification
#'
#' @description This set of functions classifies sanitation facilities according to various criteria. It includes functions to categorize sanitation facility types, sharing status, number of individuals sharing, and JMP (Joint Monitoring Programme) classification.
#'
#' @param df A data frame containing sanitation facility information.
#' @param sanitation_facility Column name for sanitation facility types.
#' @param improved Character vector of response codes for Improved facilities.
#' @param unimproved Character vector of response codes for Unimproved facilities.
#' @param none Character vector of response codes for No sanitation facility/Open defecation.
#' @param undefined Character vector of response codes that do not fit any category, e.g., c("dnk", "pnta", "other").
#'
#' @return A data frame with an additional column:
#'
#' * wash_sanitation_facility_cat: Categorized sanitation facility: "none", "unimproved", "improved", or "undefined".
#'
#' @export
add_sanitation_facility_cat <- function(df,
                                        sanitation_facility = "wash_sanitation_facility",
                                        improved = c("flush_piped_sewer", "flush_septic_tank", "flush_pit_latrine", "flush_dnk_where", "pit_latrine_slab", "twin_pit_latrine_slab", "ventilated_pit_latrine_slab", "container", "compost"),
                                        unimproved = c("flush_open_drain", "flush_elsewhere", "pit_latrine_wo_slab", "bucket", "hanging_toilet", "plastic_bag"),
                                        none = "none",
                                        undefined = c("other", "dnk", "pnta")
                                        ) {

  #------ Checks

  # Check if the variable is in the data frame
  if_not_in_stop(df, sanitation_facility, "df")

  # Check values ranges
  are_values_in_set(df, sanitation_facility, c(improved, unimproved, none, undefined))

  #------ Recode sanitation facility
  df <- dplyr::mutate(
    df,
    wash_sanitation_facility_cat = dplyr::case_when(
      !!rlang::sym(sanitation_facility) %in% none ~ "none",
      !!rlang::sym(sanitation_facility) %in% unimproved ~ "unimproved",
      !!rlang::sym(sanitation_facility) %in% improved ~ "improved",
      !!rlang::sym(sanitation_facility) %in% undefined ~ "undefined",
      .default = NA_character_)
  )

  return(df)
}



#' @rdname add_sanitation_facility_cat
#'
#' @title Add Sharing Status of Sanitation Facility
#'
#' @description This function recodes the sharing status of sanitation facilities based on user responses. It categorizes whether the facility is shared or not shared and handles cases where the facility was skipped.
#'
#' @param df A data frame containing sharing status information.
#' @param sharing_sanitation_facility Component column: Number of people with whom the facility is shared.
#' @param yes Character vector of response codes for Yes.
#' @param no Character vector of response codes for No.
#' @param skipped_sanitation_facility Character vector of response codes for skipped sanitation facility.
#' @param undefined Character vector of response codes indicating undefined responses (e.g., c("dnk", "pnta")).
#'
#' @return A data frame with an additional column:
#'
#' * wash_sharing_sanitation_facility_cat: Categorized sharing status: "shared", "not_shared", or "not_applicable".
#'
#' @export
add_sharing_sanitation_facility_cat <- function(df,
                                            sharing_sanitation_facility = "wash_sanitation_facility_sharing_yn",
                                            yes = "yes",
                                            no = "no",
                                            undefined = c("dnk", "pnta"),
                                            sanitation_facility = "wash_sanitation_facility",
                                            skipped_sanitation_facility = NULL
) {

  #------ Check values ranges
  are_values_in_set(df, sharing_sanitation_facility, c(yes, no, undefined))
  if (!is.null(skipped_sanitation_facility)) {
    are_values_in_set(df, sanitation_facility, skipped_sanitation_facility)
  }
  # are_cols_numeric(df, sharing_sanitation_facility)

  # If sanitation_facility was skipped because of sharing_sanitation_facility, then recode sharing_sanitation_facility to "no"
  if (!is.null(skipped_sanitation_facility)) {
    df <- dplyr::mutate(
      df,
      wash_sharing_sanitation_facility_cat = dplyr::case_when(
        !!rlang::sym(sanitation_facility) %in% skipped_sanitation_facility ~ "not_applicable",
        !!rlang::sym(sharing_sanitation_facility) == yes ~ "shared",
        !!rlang::sym(sharing_sanitation_facility) == no ~ "not_shared",
        !!rlang::sym(sharing_sanitation_facility) %in% undefined ~ "undefined",
        .default = NA_character_
      )
    )
  } else {
    df <- dplyr::mutate(
      df,
      wash_sharing_sanitation_facility_cat = dplyr::case_when(
        !!rlang::sym(sharing_sanitation_facility) == yes ~ "shared",
        !!rlang::sym(sharing_sanitation_facility) == no ~ "not_shared",
        !!rlang::sym(sharing_sanitation_facility) %in% undefined ~ "undefined",
        .default = NA_character_
      )
    )
  }

  return(df)
}

#' @rdname add_sanitation_facility_cat
#'
#' @title Add Number of Households Sharing a Sanitation Facility
#'
#' @description This function calculates the number of households sharing a sanitation facility and categorizes them based on predefined thresholds. It also handles the household size and survey weights in calculations.
#'
#' @param df A data frame containing household-level data.
#' @param sharing_sanitation_facility_cat Component column: Is the sanitation facility shared?
#' @param sharing_sanitation_facility_cat_shared Response code for shared facilities.
#' @param sharing_sanitation_facility_cat_not_shared Response code for not shared facilities.
#' @param sharing_sanitation_facility_cat_not_applicable Response code for not applicable cases.
#' @param sharing_sanitation_facility_cat_undefined Response code for undefined cases.
#' @param sanitation_facility_sharing_n Component column: Number of households sharing the sanitation facility.
#' @param hh_size Column name for household size.
#' @param weight Column name for survey weights.
#'
#' @return A data frame with an additional column:
#'
#' * wash_sharing_sanitation_n_ind: Categorized number of individuals sharing a sanitation facility.
#'
#' @export
add_sharing_sanitation_facility_n_ind <- function(
    df,
    sharing_sanitation_facility_cat = "wash_sharing_sanitation_facility_cat",
    sharing_sanitation_facility_cat_shared = "shared",
    sharing_sanitation_facility_cat_not_shared = "not_shared",
    sharing_sanitation_facility_cat_not_applicable = "not_applicable",
    sharing_sanitation_facility_cat_undefined = "undefined",
    sanitation_facility_sharing_n = "wash_sanitation_facility_sharing_n",
    hh_size = "hh_size",
    weight = "weight"){

  #------ Checks

  # Check if the variable is in the data frame
  if_not_in_stop(df, sharing_sanitation_facility_cat, "df")
  if_not_in_stop(df, sanitation_facility_sharing_n, "df")
  if_not_in_stop(df, hh_size, "df")

  # Create levels vector
  levels <- c(sharing_sanitation_facility_cat_shared,
              sharing_sanitation_facility_cat_not_shared,
              sharing_sanitation_facility_cat_not_applicable,
              sharing_sanitation_facility_cat_undefined)

  # Check if all values of sharing_sanitation_facility_d are in levels
  are_values_in_set(df, sharing_sanitation_facility_cat, levels)

  # Check if household size and sharing_sanitation_facility_number_hh are num
  are_cols_numeric(df, c(sanitation_facility_sharing_n, hh_size))

  #------ Calculate the mean household size
  mean_hh_size <- stats::weighted.mean(df[[hh_size]], df[[weight]], na.rm = TRUE)

  #------ Recode the number of people sharing a sanitation facility
  df <- dplyr::mutate(
    df,
    "{sanitation_facility_sharing_n}" := dplyr::case_when(
      # If facility shared
      !!rlang::sym(sharing_sanitation_facility_cat) == sharing_sanitation_facility_cat_shared ~
        (!!rlang::sym(sanitation_facility_sharing_n) - 1) * mean_hh_size + !!rlang::sym(hh_size),
      # If facility not shared
      !!rlang::sym(sharing_sanitation_facility_cat) == sharing_sanitation_facility_cat_not_shared  ~
        !!rlang::sym(hh_size),
      .default = NA_real_
    )
  )

  #------ Recode sanitation facility
  df <- dplyr::mutate(
    df,
    wash_sharing_sanitation_facility_n_ind = dplyr::case_when(
      !!rlang::sym(sanitation_facility_sharing_n) >= 50 ~ "50_and_above",
      !!rlang::sym(sanitation_facility_sharing_n) >= 20 ~ "20_to_49",
      !!rlang::sym(sanitation_facility_sharing_n) >= 0 ~ "19_and_below",
      .default = NA_character_)
  )

  return(df)
}


#' @rdname add_sanitation_facility_cat
#'
#' @title Combine Sanitation Facility Classification and Sharing Status
#'
#' @description This function combines the previous two functions to recode the sanitation facility into a JMP classification. It also includes information about whether the facility is shared or not shared.
#'
#' @param df A data frame containing both sanitation facility types and sharing status information.
#' @param sanitation_facility_cat Component column: Sanitation facility types recoded.
#' @param sanitation_facility_cat_improved Level: Improved sanitation facility.
#' @param sanitation_facility_cat_unimproved Level: Unimproved sanitation facility.
#' @param sanitation_facility_cat_none Level: No sanitation facility.
#' @param sanitation_facility_cat_undefined Level: Undefined sanitation facility.
#' @param sharing_sanitation_facility_cat Component column: Sharing status of sanitation facility recoded.
#' @param sharing_sanitation_facility_cat_shared Level: Shared sanitation facility.
#' @param sharing_sanitation_facility_cat_not_shared Level: Not shared sanitation facility.
#' @param sharing_sanitation_facility_cat_not_applicable Level: Not applicable sharing status.
#' @param sharing_sanitation_facility_cat_undefined Level: Undefined sharing status.
#'
#' @return A data frame with an additional column:
#'
#' * wash_sanitization_jmp_cat: Categorized JMP classification based on both type and sharing status.
#'
#' @export
add_sanitation_facility_jmp_cat <- function(
    df,
    sanitation_facility_cat = "wash_sanitation_facility_cat",
    sanitation_facility_cat_improved = "improved",
    sanitation_facility_cat_unimproved = "unimproved",
    sanitation_facility_cat_none = "none",
    sanitation_facility_cat_undefined = "undefined",
    sharing_sanitation_facility_cat = "wash_sharing_sanitation_facility_cat",
    sharing_sanitation_facility_cat_shared = "shared",
    sharing_sanitation_facility_cat_not_shared = "not_shared",
    sharing_sanitation_facility_cat_not_applicable = "not_applicable",
    sharing_sanitation_facility_cat_undefined = "undefined"){

  #------ Checks

  # Check if vars exist
  if_not_in_stop(df, c(sanitation_facility_cat, sharing_sanitation_facility_cat), "df")

  # Check values of levels
  sanitation_levels <- c(sanitation_facility_cat_improved, sanitation_facility_cat_unimproved,
                         sanitation_facility_cat_none, sanitation_facility_cat_undefined)
  sharing_levels <- c(sharing_sanitation_facility_cat_shared, sharing_sanitation_facility_cat_not_shared,
                      sharing_sanitation_facility_cat_not_applicable, sharing_sanitation_facility_cat_undefined)
  are_values_in_set(df, sanitation_facility_cat, sanitation_levels)
  are_values_in_set(df, sharing_sanitation_facility_cat, sharing_levels)

  #------ Recode

  # Recode sanitation facility
  df <- dplyr::mutate(
    df,
    wash_sanitation_facility_jmp_cat = dplyr::case_when(
      !!rlang::sym(sanitation_facility_cat) == sanitation_facility_cat_none ~ "open_defecation",
      !!rlang::sym(sanitation_facility_cat) == sanitation_facility_cat_unimproved ~ "unimproved",
      !!rlang::sym(sanitation_facility_cat) == sanitation_facility_cat_improved &
        !!rlang::sym(sharing_sanitation_facility_cat) == sharing_sanitation_facility_cat_shared ~ "limited",
      !!rlang::sym(sanitation_facility_cat) == sanitation_facility_cat_improved &
        !!rlang::sym(sharing_sanitation_facility_cat) == sharing_sanitation_facility_cat_not_shared ~ "basic",
      !!rlang::sym(sanitation_facility_cat) == sanitation_facility_cat_undefined ~ "undefined",
      !!rlang::sym(sharing_sanitation_facility_cat) %in% c(sharing_sanitation_facility_cat_not_applicable,
                                                           sharing_sanitation_facility_cat_undefined) ~ "undefined",
      .default = NA_character_)
  )

  return(df)

}
