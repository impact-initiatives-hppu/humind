#' Sanitation facility classification
#'
#' [add_sanitation_facility_cat()] recodes the types of sanitation facilities, [add_sharing_sanitation_facility_cat()] recodes the sharing status of sanitation facility, and [add_sanitation_facility_jmp_cat()] combines the previous two functions to recode the sanitation facility into a JMP classification. Finally, [add_sharing_sanitation_facility_n_ind()] recodes the number of individuals sharing the sanitation facility.
#'
#' @param df A data frame.
#' @param sanitation_facility Component column: Sanitation facility types.
#' @param improved Character vector of responses codes for Improved facilities.
#' @param unimproved Character vector of responses codes for Unimproved facilities.
#' @param none Character vector of responses codes for No sanitation facility/Open defecation.
#' @param undefined Character vector of responses codes, that do not fit any category, e.g., c("dnk", "pnta", "other").
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
#' @param sharing_sanitation_facility Component column: Number of people with whom the facility is shared.
#' @param yes Character vector of responses codes for Yes.
#' @param no Character vector of responses codes for No.
#' @param skipped_sanitation_facility Character vector of responses codes for skipped sanitation facility.
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
#' @param sharing_sanitation_facility_cat Component column: is the sanitation facility shared.
#' @param levels Character vector of responses codes, including first in the following order: Shared, Not shared, Not applicable, and Undefined.
#' @param sanitation_facility_sharing_n Component column: number of households sharing the sanitation facility.
#' @param hh_size Column of the household size.
#' @param weight Column of the survey weights.
#'
#' @export
add_sharing_sanitation_facility_n_ind <- function(
    df,
    sharing_sanitation_facility_cat = "wash_sharing_sanitation_facility_cat",
    levels = c("shared", "not_shared", "not_applicable", "undefined"),
    sanitation_facility_sharing_n = "wash_sanitation_facility_sharing_n",
    hh_size = "hh_size",
    weight = "weight"){

  #------ Checks

  # Check if the variable is in the data frame
  if_not_in_stop(df, sharing_sanitation_facility_cat, "df")
  if_not_in_stop(df, sanitation_facility_sharing_n, "df")
  if_not_in_stop(df, hh_size, "df")

  # Check if length of levels is 4
  if (length(levels) != 4) {
    rlang::abort("Levels should be of length 4.")
  }

  # Check if all values of sharing_sanitation_facility_d are in levels
  are_values_in_set(df, sharing_sanitation_facility_cat, levels)

  # Check if household size and sharing_sanitation_facility_number_hh are num
  are_cols_numeric(df, c(sanitation_facility_sharing_n, hh_size))

  #------ Calculate the mean household size
  mean_hh_size <- stats::weighted.mean(df[[hh_size]], df[[weight]], na.rm = TRUE)

  #------ Calculate the number of households the household share the sanitation facility with
  # if isFalse(incl_hh), the household is already included, hence, minus 1
  # df <- dplyr::mutate(
  #   df,
  #   wash_sharing_sanitation_facility_num_hh = dplyr::case_when(
  #     incl_hh ~ !!rlang::sym(sharing_sanitation_facility_number_hh),
  #     !incl_hh ~ !!rlang::sym(sharing_sanitation_facility_number_hh) - 1,
  #     .default = NA_real_
  #   )
  # )

  #------ Recode the number of people sharing a sanitation facility
  df <- dplyr::mutate(
    df,
    "{sanitation_facility_sharing_n}" := dplyr::case_when(
      # If facility shared
      !!rlang::sym(sharing_sanitation_facility_cat) == levels[1] ~ (!!rlang::sym(sanitation_facility_sharing_n) - 1) * mean_hh_size + !!rlang::sym(hh_size),
      # If facility not shared
      !!rlang::sym(sharing_sanitation_facility_cat) == levels[2]  ~ !!rlang::sym(hh_size),
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
#' @param sanitation_facility_cat Component column: Sanitation facility types recoded.
#' @param sanitation_facility_levels Levels: Improved, Unimproved, None, Undefined.
#' @param sharing_sanitation_facility_cat Component column: Sharing status of sanitation facility recoded.
#' @param sharing_sanitation_facility_levels Levels: Shared, Not shared, Not applicable, Undefined.
#'
#' @export
add_sanitation_facility_jmp_cat <- function(
  df,
  sanitation_facility_cat = "wash_sanitation_facility_cat",
  sanitation_facility_levels = c("improved", "unimproved", "none", "undefined"),
  sharing_sanitation_facility_cat = "wash_sharing_sanitation_facility_cat",
  sharing_sanitation_facility_levels = c("shared", "not_shared", "not_applicable", "undefined")){

  #------ Checks

  # Check if vars exist
  if_not_in_stop(df, c(sanitation_facility_cat, sharing_sanitation_facility_cat), "df")

  # Check length of levels
  if (length(sanitation_facility_levels) != 4) {
    rlang::abort("sanitation_facility_levels should be of length 4.")
  }
  if (length(sharing_sanitation_facility_levels) != 4) {
    rlang::abort("sharing_sanitation_facility_levels should be of length 4.")
  }

  # Check values of levels
  are_values_in_set(df, sanitation_facility_cat, sanitation_facility_levels)
  are_values_in_set(df, sharing_sanitation_facility_cat, sharing_sanitation_facility_levels)

  #------ Recode

  # Recode sanitation facility
  df <- dplyr::mutate(
    df,
    wash_sanitation_facility_jmp_cat = dplyr::case_when(
      !!rlang::sym(sanitation_facility_cat) == sanitation_facility_levels[3] ~ "open_defecation",
      !!rlang::sym(sanitation_facility_cat) == sanitation_facility_levels[2] ~ "unimproved",
      !!rlang::sym(sanitation_facility_cat) == sanitation_facility_levels[1] & 
        !!rlang::sym(sharing_sanitation_facility_cat) == sharing_sanitation_facility_levels[1] ~ "limited",
      !!rlang::sym(sanitation_facility_cat) == sanitation_facility_levels[1] & 
        sharing_sanitation_facility_cat == sharing_sanitation_facility_levels[1] & 
        !!rlang::sym(sharing_sanitation_facility_cat) == sharing_sanitation_facility_levels[2] ~ "basic",
      !!rlang::sym(sanitation_facility_cat) == sanitation_facility_levels[4] ~ "undefined",
      !!rlang::sym(sharing_sanitation_facility_cat) %in% sharing_sanitation_facility_levels[3:4] ~ "undefined",
      .default = NA_character_)
    )

    return(df)

}

