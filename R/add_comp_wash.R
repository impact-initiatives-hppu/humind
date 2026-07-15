#' @title Add WASH Sectoral Composite Score and Need Indicator
#'
#' @description
#' Calculates a comprehensive WASH (Water, Sanitation, and Hygiene) composite score
#' for households across different settings (camp, urban, rural). The function
#' generates sub-scores for water quantity, water quality, sanitation, and hygiene,
#' and creates a dummy variable to indicate households in need of WASH assistance.
#'
#' The function performs detailed scoring based on multiple WASH-related variables,
#' applying different scoring logic for camp, urban, and rural settings.
#'
#' Prerequisite functions:
#'
#' * [add_hwise()]
#' * [add_drinking_water_source_cat()]
#' * [add_drinking_water_time_cat()]
#' * [add_drinking_water_time_threshold_cat()]
#' * [add_drinking_water_quality_jmp_cat()]
#' * [add_sanitation_facility_cat()]
#' * [add_sharing_sanitation_facility_cat()]
#' * [add_sharing_sanitation_facility_n_ind()]
#' * [add_sanitation_facility_jmp_cat()]
#' * [add_handwashing_facility_cat()]
#'
#'
#' @param df A data frame containing the required WASH-related variables.
#' @param setting Column name for the setting (camp, urban, or rural).
#' @param setting_camp Setting value(s) for camp.
#' @param setting_urban Setting value for urban.
#' @param setting_rural Setting value for rural.
#' @param comp_wash_hwise_score Column name for the pre-computed HWISE water
#'   quantity severity score (1–5), as produced by [add_hwise()].
#' @param drinking_water_quality_jmp_cat Column name for drinking water quality JMP category.
#' @param drinking_water_quality_jmp_cat_surface_water Value for "surface water" in drinking water quality JMP category.
#' @param drinking_water_quality_jmp_cat_unimproved Value for "unimproved" in drinking water quality JMP category.
#' @param drinking_water_quality_jmp_cat_limited Value for "limited" in drinking water quality JMP category.
#' @param drinking_water_quality_jmp_cat_basic Value for "basic" in drinking water quality JMP category.
#' @param drinking_water_quality_jmp_cat_safely_managed Value for "safely managed" in drinking water quality JMP category.
#' @param drinking_water_quality_jmp_cat_undefined Value for "undefined" in drinking water quality JMP category.
#' @param sanitation_facility_jmp_cat Column name for sanitation facility JMP category.
#' @param sanitation_facility_jmp_cat_open_defecation Value for "open defecation" in sanitation facility JMP category.
#' @param sanitation_facility_jmp_cat_unimproved Value for "unimproved" in sanitation facility JMP category.
#' @param sanitation_facility_jmp_cat_limited Value for "limited" in sanitation facility JMP category.
#' @param sanitation_facility_jmp_cat_basic Value for "basic" in sanitation facility JMP category.
#' @param sanitation_facility_jmp_cat_undefined Value for "undefined" in sanitation facility JMP category.
#' @param sanitation_facility_cat Column name for sanitation facility category.
#' @param sanitation_facility_cat_none Value for "none" in sanitation facility category.
#' @param sanitation_facility_cat_unimproved Value for "unimproved" in sanitation facility category.
#' @param sanitation_facility_cat_improved Value for "improved" in sanitation facility category.
#' @param sanitation_facility_cat_undefined Value for "undefined" in sanitation facility category.
#' @param sanitation_facility_n_ind Column name for number of individuals using the sanitation facility.
#' @param sanitation_facility_n_ind_50_and_above Value for "50 and above" in number of individuals using the sanitation facility.
#' @param sanitation_facility_n_ind_20_to_49 Value for "20 to 49" in number of individuals using the sanitation facility.
#' @param sanitation_facility_n_ind_19_and_below Value for "19 and below" in number of individuals using the sanitation facility.
#' @param sharing_sanitation_facility_cat Column name for sharing a sanitation facility.
#' @param sharing_sanitation_facility_cat_shared Value for "shared" in sharing a sanitation facility.
#' @param sharing_sanitation_facility_cat_not_shared Value for "not shared" in sharing a sanitation facility.
#' @param sharing_sanitation_facility_cat_not_applicable Value for "not applicable" in sharing a sanitation facility.
#' @param sharing_sanitation_facility_cat_undefined Value for "undefined" in sharing a sanitation facility.
#' @param handwashing_facility_jmp_cat Column name for handwashing facility JMP category.
#' @param handwashing_facility_jmp_cat_no_facility Value for "no facility" in handwashing facility JMP category.
#' @param handwashing_facility_jmp_cat_limited Value for "limited" in handwashing facility JMP category.
#' @param handwashing_facility_jmp_cat_basic Value for "basic" in handwashing facility JMP category.
#' @param handwashing_facility_jmp_cat_undefined Value for "undefined" in handwashing facility JMP category.
#'
#' @return A data frame with new columns:
#'
#' * comp_wash_score_water_quantity: Numeric score for water quantity (1-5).
#' * comp_wash_score_water_quality: Numeric score for water quality (1-5).
#' * comp_wash_score_sanitation: Numeric score for sanitation (1-5).
#' * comp_wash_score_hygiene: Numeric score for hygiene (1-5).
#' * comp_wash_score: Overall WASH composite score (0-20).
#' * comp_wash_in_need: Binary indicator (0 or 1) for households in need of WASH assistance.
#'
#' @export
add_comp_wash <- function(
  df,
  setting = "setting",
  setting_camp = c("camp_formal", "camp_informal"),
  setting_urban = "urban",
  setting_rural = "rural",
  comp_wash_hwise_score = "comp_wash_score_water_quantity",
  drinking_water_quality_jmp_cat = "wash_drinking_water_quality_jmp_cat",
  drinking_water_quality_jmp_cat_surface_water = "surface_water",
  drinking_water_quality_jmp_cat_unimproved = "unimproved",
  drinking_water_quality_jmp_cat_limited = "limited",
  drinking_water_quality_jmp_cat_basic = "basic",
  drinking_water_quality_jmp_cat_safely_managed = "safely_managed",
  drinking_water_quality_jmp_cat_undefined = "undefined",
  sanitation_facility_jmp_cat = "wash_sanitation_facility_jmp_cat",
  sanitation_facility_jmp_cat_open_defecation = "open_defecation",
  sanitation_facility_jmp_cat_unimproved = "unimproved",
  sanitation_facility_jmp_cat_limited = "limited",
  sanitation_facility_jmp_cat_basic = "basic",
  sanitation_facility_jmp_cat_undefined = "undefined",
  sanitation_facility_cat = "wash_sanitation_facility_cat",
  sanitation_facility_cat_none = "none",
  sanitation_facility_cat_unimproved = "unimproved",
  sanitation_facility_cat_improved = "improved",
  sanitation_facility_cat_undefined = "undefined",
  sanitation_facility_n_ind = "wash_sharing_sanitation_facility_n_ind",
  sanitation_facility_n_ind_50_and_above = "50_and_above",
  sanitation_facility_n_ind_20_to_49 = "20_to_49",
  sanitation_facility_n_ind_19_and_below = "19_and_below",
  sharing_sanitation_facility_cat = "wash_sharing_sanitation_facility_cat",
  sharing_sanitation_facility_cat_shared = "shared",
  sharing_sanitation_facility_cat_not_shared = "not_shared",
  sharing_sanitation_facility_cat_not_applicable = "not_applicable",
  sharing_sanitation_facility_cat_undefined = "undefined",
  handwashing_facility_jmp_cat = "wash_handwashing_facility_jmp_cat",
  handwashing_facility_jmp_cat_no_facility = "no_facility",
  handwashing_facility_jmp_cat_limited = "limited",
  handwashing_facility_jmp_cat_basic = "basic",
  handwashing_facility_jmp_cat_undefined = "undefined"
) {
  #------ Checks

  # Check if the variables are in the data frame
  if_not_in_stop(
    df,
    c(
      setting,
      comp_wash_hwise_score,
      drinking_water_quality_jmp_cat,
      sanitation_facility_jmp_cat,
      sanitation_facility_cat,
      sanitation_facility_n_ind,
      sharing_sanitation_facility_cat,
      handwashing_facility_jmp_cat
    ),
    "df"
  )

  # Check if values are in set
  are_values_in_set(df, setting, c(setting_camp, setting_urban, setting_rural))
  are_values_in_set(df, comp_wash_hwise_score, 1:5)
  are_values_in_set(
    df,
    drinking_water_quality_jmp_cat,
    c(
      drinking_water_quality_jmp_cat_surface_water,
      drinking_water_quality_jmp_cat_unimproved,
      drinking_water_quality_jmp_cat_limited,
      drinking_water_quality_jmp_cat_basic,
      drinking_water_quality_jmp_cat_safely_managed,
      drinking_water_quality_jmp_cat_undefined
    )
  )
  are_values_in_set(
    df,
    sanitation_facility_jmp_cat,
    c(
      sanitation_facility_jmp_cat_open_defecation,
      sanitation_facility_jmp_cat_unimproved,
      sanitation_facility_jmp_cat_limited,
      sanitation_facility_jmp_cat_basic,
      sanitation_facility_jmp_cat_undefined
    )
  )
  are_values_in_set(
    df,
    sanitation_facility_cat,
    c(
      sanitation_facility_cat_none,
      sanitation_facility_cat_unimproved,
      sanitation_facility_cat_improved,
      sanitation_facility_cat_undefined
    )
  )
  are_values_in_set(
    df,
    sanitation_facility_n_ind,
    c(
      sanitation_facility_n_ind_50_and_above,
      sanitation_facility_n_ind_20_to_49,
      sanitation_facility_n_ind_19_and_below
    )
  )
  are_values_in_set(
    df,
    handwashing_facility_jmp_cat,
    c(
      handwashing_facility_jmp_cat_no_facility,
      handwashing_facility_jmp_cat_limited,
      handwashing_facility_jmp_cat_basic,
      handwashing_facility_jmp_cat_undefined
    )
  )
  are_values_in_set(
    df,
    sharing_sanitation_facility_cat,
    c(
      sharing_sanitation_facility_cat_shared,
      sharing_sanitation_facility_cat_not_shared,
      sharing_sanitation_facility_cat_not_applicable,
      sharing_sanitation_facility_cat_undefined
    )
  )

  #------ Recode

  # Dimensions - sub-composites
  df <- dplyr::mutate(
    df,
    comp_wash_score_water_quality = dplyr::case_when(
      # Safely managed is always 1
      !!rlang::sym(drinking_water_quality_jmp_cat) %in%
        drinking_water_quality_jmp_cat_safely_managed ~
        1,
      # Camp
      !!rlang::sym(setting) %in% setting_camp &
        !!rlang::sym(drinking_water_quality_jmp_cat) %in%
          drinking_water_quality_jmp_cat_surface_water ~
        4,
      !!rlang::sym(setting) %in% setting_camp &
        !!rlang::sym(drinking_water_quality_jmp_cat) %in%
          drinking_water_quality_jmp_cat_unimproved ~
        3,
      !!rlang::sym(setting) %in% setting_camp &
        !!rlang::sym(drinking_water_quality_jmp_cat) %in%
          drinking_water_quality_jmp_cat_limited ~
        2,
      !!rlang::sym(setting) %in% setting_camp &
        !!rlang::sym(drinking_water_quality_jmp_cat) %in%
          drinking_water_quality_jmp_cat_basic ~
        1,
      !!rlang::sym(setting) %in% setting_camp &
        !!rlang::sym(drinking_water_quality_jmp_cat) %in%
          drinking_water_quality_jmp_cat_undefined ~
        NA_real_,
      # Urban
      !!rlang::sym(setting) == setting_urban &
        !!rlang::sym(drinking_water_quality_jmp_cat) %in%
          drinking_water_quality_jmp_cat_surface_water ~
        4,
      !!rlang::sym(setting) == setting_urban &
        !!rlang::sym(drinking_water_quality_jmp_cat) %in%
          drinking_water_quality_jmp_cat_unimproved ~
        3,
      !!rlang::sym(setting) == setting_urban &
        !!rlang::sym(drinking_water_quality_jmp_cat) %in%
          c(
            drinking_water_quality_jmp_cat_limited
          ) ~
        2,
      !!rlang::sym(setting) == setting_urban &
        !!rlang::sym(drinking_water_quality_jmp_cat) %in%
          c(
            drinking_water_quality_jmp_cat_basic # Grouped with safely managed, which is set to 1 at the begnning of the conditional branch
          ) ~
        1,
      !!rlang::sym(setting) == setting_urban &
        !!rlang::sym(drinking_water_quality_jmp_cat) %in%
          drinking_water_quality_jmp_cat_undefined ~
        NA_real_,
      # Rural
      !!rlang::sym(setting) == setting_rural &
        !!rlang::sym(drinking_water_quality_jmp_cat) %in%
          drinking_water_quality_jmp_cat_surface_water ~
        4,
      !!rlang::sym(setting) == setting_rural &
        !!rlang::sym(drinking_water_quality_jmp_cat) %in%
          c(
            drinking_water_quality_jmp_cat_limited
          ) ~
        2,
      !!rlang::sym(setting) == setting_rural &
        !!rlang::sym(drinking_water_quality_jmp_cat) %in%
          c(
            drinking_water_quality_jmp_cat_unimproved
          ) ~
        3,
      !!rlang::sym(setting) == setting_rural &
        !!rlang::sym(drinking_water_quality_jmp_cat) %in%
          drinking_water_quality_jmp_cat_basic ~
        1,
      !!rlang::sym(setting) == setting_rural &
        !!rlang::sym(drinking_water_quality_jmp_cat) %in%
          drinking_water_quality_jmp_cat_undefined ~
        NA_real_,
      # Default
      .default = NA_real_
    ),
    comp_wash_score_sanitation = dplyr::case_when(
      # Camp---does not use the JMP categories
      # - Open defecation
      !!rlang::sym(setting) %in% setting_camp &
        !!rlang::sym(sanitation_facility_cat) == sanitation_facility_cat_none ~
        5,
      # - Unimproved
      !!rlang::sym(setting) %in% setting_camp &
        !!rlang::sym(sanitation_facility_cat) ==
          sanitation_facility_cat_unimproved ~
        4,
      # - Improved and shared with more than 50 people
      !!rlang::sym(setting) %in% setting_camp &
        !!rlang::sym(sanitation_facility_cat) ==
          sanitation_facility_cat_improved &
        !!rlang::sym(sanitation_facility_n_ind) ==
          sanitation_facility_n_ind_50_and_above ~
        4,
      # - Improved and shared with between 20 and 49 people
      !!rlang::sym(setting) %in% setting_camp &
        !!rlang::sym(sanitation_facility_cat) ==
          sanitation_facility_cat_improved &
        !!rlang::sym(sanitation_facility_n_ind) ==
          sanitation_facility_n_ind_20_to_49 ~
        3,
      # - Improved and shared with less than 20 people
      !!rlang::sym(setting) %in% setting_camp &
        !!rlang::sym(sanitation_facility_cat) ==
          sanitation_facility_cat_improved &
        !!rlang::sym(sanitation_facility_n_ind) ==
          sanitation_facility_n_ind_19_and_below &
        !!rlang::sym(sharing_sanitation_facility_cat) ==
          sharing_sanitation_facility_cat_shared ~
        2,
      # - Improved and not shared with people outside of the household
      !!rlang::sym(setting) %in% setting_camp &
        !!rlang::sym(sanitation_facility_cat) ==
          sanitation_facility_cat_improved &
        !!rlang::sym(sanitation_facility_n_ind) ==
          sanitation_facility_n_ind_19_and_below &
        !!rlang::sym(sharing_sanitation_facility_cat) ==
          sharing_sanitation_facility_cat_not_shared ~
        1,
      # - Improved and "not applicable" for sharing with people outside of the household
      !!rlang::sym(setting) %in% setting_camp &
        !!rlang::sym(sanitation_facility_cat) ==
          sanitation_facility_cat_improved &
        !!rlang::sym(sharing_sanitation_facility_cat) ==
          sharing_sanitation_facility_cat_not_applicable ~
        1,
      # - Undefined
      !!rlang::sym(setting) %in% setting_camp &
        !!rlang::sym(sanitation_facility_cat) ==
          sanitation_facility_cat_undefined ~
        NA_real_,
      # - Missing sanitation_facility_n_ind
      !!rlang::sym(setting) %in% setting_camp &
        is.na(!!rlang::sym(sanitation_facility_n_ind)) ~
        NA_real_,
      # Urban---uses the JMP categories
      !!rlang::sym(setting) == setting_urban &
        !!rlang::sym(sanitation_facility_cat) == sanitation_facility_cat_none &
        !!rlang::sym(sanitation_facility_jmp_cat) ==
          sanitation_facility_jmp_cat_open_defecation ~
        4,
      !!rlang::sym(setting) == setting_urban &
        !!rlang::sym(sanitation_facility_jmp_cat) ==
          sanitation_facility_jmp_cat_unimproved ~
        3,
      !!rlang::sym(setting) == setting_urban &
        !!rlang::sym(sanitation_facility_jmp_cat) ==
          sanitation_facility_jmp_cat_limited ~
        2,
      !!rlang::sym(setting) == setting_urban &
        !!rlang::sym(sanitation_facility_jmp_cat) %in%
          sanitation_facility_jmp_cat_basic ~
        1,
      !!rlang::sym(setting) == setting_urban &
        !!rlang::sym(sanitation_facility_jmp_cat) ==
          sanitation_facility_jmp_cat_undefined ~
        NA_real_,
      # Rural---uses the JMP categories
      !!rlang::sym(setting) == setting_rural &
        !!rlang::sym(sanitation_facility_cat) == sanitation_facility_cat_none &
        !!rlang::sym(sanitation_facility_jmp_cat) ==
          sanitation_facility_jmp_cat_open_defecation ~
        3,
      !!rlang::sym(setting) == setting_rural &
        !!rlang::sym(sanitation_facility_jmp_cat) %in%
          c(
            sanitation_facility_jmp_cat_unimproved,
            sanitation_facility_jmp_cat_limited
          ) ~
        2,
      !!rlang::sym(setting) == setting_rural &
        !!rlang::sym(sanitation_facility_jmp_cat) %in%
          sanitation_facility_jmp_cat_basic ~
        1,
      !!rlang::sym(setting) == setting_rural &
        !!rlang::sym(sanitation_facility_jmp_cat) ==
          sanitation_facility_jmp_cat_undefined ~
        NA_real_,
      # Default
      .default = NA_real_
    ),
    comp_wash_score_hygiene = dplyr::case_when(
      # Camp and Urban are the same
      !!rlang::sym(setting) %in% c(setting_camp, setting_urban) &
        !!rlang::sym(handwashing_facility_jmp_cat) ==
          handwashing_facility_jmp_cat_no_facility ~
        3,
      !!rlang::sym(setting) %in% c(setting_camp, setting_urban) &
        !!rlang::sym(handwashing_facility_jmp_cat) ==
          handwashing_facility_jmp_cat_limited ~
        2,
      !!rlang::sym(setting) %in% c(setting_camp, setting_urban) &
        !!rlang::sym(handwashing_facility_jmp_cat) ==
          handwashing_facility_jmp_cat_basic ~
        1,
      !!rlang::sym(setting) %in% c(setting_camp, setting_urban) &
        !!rlang::sym(handwashing_facility_jmp_cat) ==
          handwashing_facility_jmp_cat_undefined ~
        NA_real_,
      # Rural
      !!rlang::sym(setting) == setting_rural &
        !!rlang::sym(handwashing_facility_jmp_cat) %in%
          c(
            handwashing_facility_jmp_cat_no_facility,
            handwashing_facility_jmp_cat_limited
          ) ~
        2,
      !!rlang::sym(setting) == setting_rural &
        !!rlang::sym(handwashing_facility_jmp_cat) ==
          handwashing_facility_jmp_cat_basic ~
        1,
      !!rlang::sym(setting) == setting_rural &
        !!rlang::sym(handwashing_facility_jmp_cat) ==
          handwashing_facility_jmp_cat_undefined ~
        NA_real_,
      .default = NA_real_
    )
  )

  # Compute total score = max
  df <- dplyr::mutate(
    df,
    comp_wash_score = pmax(
      !!!rlang::syms(c(
        comp_wash_hwise_score,
        "comp_wash_score_water_quality",
        "comp_wash_score_sanitation",
        "comp_wash_score_hygiene"
      )),
      na.rm = TRUE
    )
  )

  # Is in need?
  df <- is_in_need(
    df,
    "comp_wash_score",
    "comp_wash_in_need"
  )

  # Is in severe need?
  df <- is_in_severe_need(
    df,
    "comp_wash_score",
    "comp_wash_in_severe_need"
  )

  df
}
