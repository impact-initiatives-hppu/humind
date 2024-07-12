#' WASH sectoral composite - add score and dummy for in need
#'
#' @param df A data frame.
#' @param setting Column name for the setting.
#' @param setting_levels Levels for the setting in that order: camp, rural, urban.
#' @param drinking_water_quantity Column name for drinking water quantity.
#' @param drinking_water_quantity_levels Levels for drinking water quantity.
#' @param drinking_water_quality_jmp_cat Column name for drinking water quality JMP category.
#' @param drinking_water_quality_jmp_cat_levels Levels for drinking water quality JMP category.
#' @param sanitation_facility_jmp_cat Column name for sanitation facility JMP category.
#' @param sanitation_facility_jmp_cat_levels Levels for sanitation facility JMP category.
#' @param sanitation_facility_cat Column name for sanitation facility category.
#' @param sanitation_facility_cat_levels Levels for sanitation facility category.
#' @param sanitation_facility_n_ind Column name for number of individuals sharing a sanitation facility.
#' @param sanitation_facility_n_ind_levels Levels for number of individuals sharing a sanitation facility.
#' @param handwashing_facility_jmp_cat Column name for handwashing facility JMP category.
#' @param handwashing_facility_jmp_cat_levels Levels for handwashing facility JMP category.
#'
#'
#' @export
add_comp_wash <- function(
    df,
    setting = "setting",
    setting_levels = c("camp", "urban", "rural"),
    drinking_water_quantity = "wash_drinking_water_quantity",
    drinking_water_quantity_levels = c("always", "often", "sometimes", "rarely", "never", "dnk", "pnta"),
    drinking_water_quality_jmp_cat = "wash_drinking_water_quality_jmp_cat",
    drinking_water_quality_jmp_cat_levels = c("surface_water", "unimproved", "limited", "basic", "safely_managed", "undefined"),
    sanitation_facility_jmp_cat = "wash_sanitation_facility_jmp_cat",
    sanitation_facility_jmp_cat_levels = c("open_defecation", "unimproved", "limited", "basic", "safely_managed", "undefined"),
    sanitation_facility_cat = "wash_sanitation_facility_cat",
    sanitation_facility_cat_levels = c("none", "unimproved", "improved", "undefined"),
    sanitation_facility_n_ind = "wash_sharing_sanitation_facility_n_ind",
    sanitation_facility_n_ind_levels = c("50_and_above", "20_to_49", "19_and_below"),
    handwashing_facility_jmp_cat = "wash_handwashing_facility_jmp_cat",
    handwashing_facility_jmp_cat_levels = c("no_facility", "limited", "basic", "undefined")
    ){

    #------ Checks

    # Check if the variables are in the data frame
    if_not_in_stop(df, c(setting, drinking_water_quantity, drinking_water_quality_jmp_cat, sanitation_facility_jmp_cat, sanitation_facility_cat, sanitation_facility_n_ind, handwashing_facility_jmp_cat), "df")

    # Check if values are in set
    are_values_in_set(df, setting, setting_levels)
    are_values_in_set(df, drinking_water_quantity, drinking_water_quantity_levels)
    are_values_in_set(df, drinking_water_quality_jmp_cat, drinking_water_quality_jmp_cat_levels)
    are_values_in_set(df, sanitation_facility_jmp_cat, sanitation_facility_jmp_cat_levels)
    are_values_in_set(df, sanitation_facility_cat, sanitation_facility_cat_levels)
    are_values_in_set(df, sanitation_facility_n_ind, sanitation_facility_n_ind_levels)
    are_values_in_set(df, handwashing_facility_jmp_cat, handwashing_facility_jmp_cat_levels)

    # Check lengths
    # Is that necessary? the remaining will be NAes
    if (length(setting_levels) != 3) {
        rlang::abort("setting_levels should be of length 3.")
    }
    if (length(drinking_water_quantity_levels) != 7) {
        rlang::abort("drinking_water_quantity_levels should be of length 7.")
    }
    if (length(drinking_water_quality_jmp_cat_levels) != 6) {
        rlang::abort("drinking_water_quality_jmp_cat_levels should be of length 6.")
    }
    if (length(sanitation_facility_jmp_cat_levels) != 6) {
        rlang::abort("sanitation_facility_jmp_cat_levels should be of length 6.")
    }
    if (length(sanitation_facility_cat_levels) != 4) {
        rlang::abort("sanitation_facility_cat_levels should be of length 4.")
    }
    if (length(sanitation_facility_n_ind_levels) != 3) {
        rlang::abort("sanitation_facility_n_ind_levels should be of length 3.")
    }
    if (length(handwashing_facility_jmp_cat_levels) != 4) {
        rlang::abort("handwashing_facility_jmp_cat_levels should be of length 4.")
    }

    #------ Recode

    # Dimensions - sub-composites
    df <- dplyr::mutate(
        df,
        comp_wash_score_water_quantity = dplyr::case_when(
            !!rlang::sym(drinking_water_quantity) %in% drinking_water_quantity_levels[1] ~ 5,
            !!rlang::sym(drinking_water_quantity) %in% drinking_water_quantity_levels[2] ~ 4,
            !!rlang::sym(drinking_water_quantity) %in% drinking_water_quantity_levels[3] ~ 3,
            !!rlang::sym(drinking_water_quantity) %in% drinking_water_quantity_levels[4] ~ 2,
            !!rlang::sym(drinking_water_quantity) %in% drinking_water_quantity_levels[5] ~ 1,
            !!rlang::sym(drinking_water_quantity) %in% drinking_water_quantity_levels[6:7] ~ NA_real_,
            .default = NA_real_
        ),
        comp_wash_score_water_quality = dplyr::case_when(
            # Safely managed is always 1
            !!rlang::sym(drinking_water_quality_jmp_cat) %in% drinking_water_quality_jmp_cat_levels[5] ~ 1,
            # Camp
            !!rlang::sym(setting) == setting_levels[1] & !!rlang::sym(drinking_water_quality_jmp_cat) %in% drinking_water_quality_jmp_cat_levels[1] ~ 5,
            !!rlang::sym(setting) == setting_levels[1] & !!rlang::sym(drinking_water_quality_jmp_cat) %in% drinking_water_quality_jmp_cat_levels[2] ~ 4,
            !!rlang::sym(setting) == setting_levels[1] & !!rlang::sym(drinking_water_quality_jmp_cat) %in% drinking_water_quality_jmp_cat_levels[3] ~ 3,
            !!rlang::sym(setting) == setting_levels[1] & !!rlang::sym(drinking_water_quality_jmp_cat) %in% drinking_water_quality_jmp_cat_levels[4] ~ 2,
            !!rlang::sym(setting) == setting_levels[1] & !!rlang::sym(drinking_water_quality_jmp_cat) %in% drinking_water_quality_jmp_cat_levels[6] ~ NA_real_,
            # Urban
            !!rlang::sym(setting) == setting_levels[2] & !!rlang::sym(drinking_water_quality_jmp_cat) %in% drinking_water_quality_jmp_cat_levels[1] ~ 4,
            !!rlang::sym(setting) == setting_levels[2] & !!rlang::sym(drinking_water_quality_jmp_cat) %in% drinking_water_quality_jmp_cat_levels[2] ~ 3,
            !!rlang::sym(setting) == setting_levels[2] & !!rlang::sym(drinking_water_quality_jmp_cat) %in% drinking_water_quality_jmp_cat_levels[3:4] ~ 2,
            !!rlang::sym(setting) == setting_levels[2] & !!rlang::sym(drinking_water_quality_jmp_cat) %in% drinking_water_quality_jmp_cat_levels[6] ~ NA_real_,
            # Rural
            !!rlang::sym(setting) == setting_levels[3] & !!rlang::sym(drinking_water_quality_jmp_cat) %in% drinking_water_quality_jmp_cat_levels[1] ~ 4,
            !!rlang::sym(setting) == setting_levels[3] & !!rlang::sym(drinking_water_quality_jmp_cat) %in% drinking_water_quality_jmp_cat_levels[2:3] ~ 2,
            !!rlang::sym(setting) == setting_levels[3] & !!rlang::sym(drinking_water_quality_jmp_cat) %in% drinking_water_quality_jmp_cat_levels[4] ~ 1,
            !!rlang::sym(setting) == setting_levels[3] & !!rlang::sym(drinking_water_quality_jmp_cat) %in% drinking_water_quality_jmp_cat_levels[6] ~ NA_real_,
            # Default
            .default = NA_real_
        ),
        comp_wash_score_sanitation = dplyr::case_when(
            # Camp---does not use the JMP categories
            # - Open defecation
            !!rlang::sym(setting) == setting_levels[1] & !!rlang::sym(sanitation_facility_cat) == sanitation_facility_cat_levels[1] ~ 5,
            # - Unimproved
            !!rlang::sym(setting) == setting_levels[1] & !!rlang::sym(sanitation_facility_cat) == sanitation_facility_cat_levels[2] ~ 4,
            # - Improved and shared with more than 50 people
            !!rlang::sym(setting) == setting_levels[1] &
                !!rlang::sym(sanitation_facility_cat) == sanitation_facility_cat_levels[3] &
                !!rlang::sym(sanitation_facility_n_ind) == sanitation_facility_n_ind_levels[1]  ~ 3,
            # - Improved and shared with between 20 and 49 people
            !!rlang::sym(setting) == setting_levels[1] &
                !!rlang::sym(sanitation_facility_cat) == sanitation_facility_cat_levels[3] &
                !!rlang::sym(sanitation_facility_n_ind) == sanitation_facility_n_ind_levels[2]  ~ 2,
            # - Improved and shared with less than 20 people
            !!rlang::sym(setting) == setting_levels[1] &
                !!rlang::sym(sanitation_facility_cat) == sanitation_facility_cat_levels[3] &
                !!rlang::sym(sanitation_facility_n_ind) == sanitation_facility_n_ind_levels[3]  ~ 1,
            # - Undefined
            !!rlang::sym(setting) == setting_levels[1] &
                !!rlang::sym(sanitation_facility_cat) == sanitation_facility_cat_levels[4] ~ NA_real_,
            # - Missing sanitation_facility_n_ind
            !!rlang::sym(setting) == setting_levels[1] &
                is.na(!!rlang::sym(sanitation_facility_n_ind)) ~ NA_real_,
            # Urban---uses the JMP categories
            !!rlang::sym(setting) == setting_levels[2] &
                !!rlang::sym(sanitation_facility_cat) == sanitation_facility_cat_levels[1] &
                !!rlang::sym(sanitation_facility_jmp_cat) == sanitation_facility_jmp_cat_levels[1] ~ 4,
            !!rlang::sym(setting) == setting_levels[2] &
                !!rlang::sym(sanitation_facility_jmp_cat) == sanitation_facility_jmp_cat_levels[2] ~ 3,
            !!rlang::sym(setting) == setting_levels[2] &
                !!rlang::sym(sanitation_facility_jmp_cat) == sanitation_facility_jmp_cat_levels[3:4] ~ 2,
            !!rlang::sym(setting) == setting_levels[2] &
                !!rlang::sym(sanitation_facility_jmp_cat) == sanitation_facility_jmp_cat_levels[5] ~ 1,
            !!rlang::sym(setting) == setting_levels[2] &
                !!rlang::sym(sanitation_facility_jmp_cat) == sanitation_facility_jmp_cat_levels[6] ~ NA_real_,
            # Rural---uses the JMP categories
            !!rlang::sym(setting) == setting_levels[3] &
                !!rlang::sym(sanitation_facility_cat) == sanitation_facility_cat_levels[1] &
                !!rlang::sym(sanitation_facility_jmp_cat) == sanitation_facility_jmp_cat_levels[1] ~ 4,
            !!rlang::sym(setting) == setting_levels[3] &
                !!rlang::sym(sanitation_facility_jmp_cat) == sanitation_facility_jmp_cat_levels[2:3] ~ 2,
            !!rlang::sym(setting) == setting_levels[3] &
                !!rlang::sym(sanitation_facility_jmp_cat) == sanitation_facility_jmp_cat_levels[4:5] ~ 1,
            !!rlang::sym(setting) == setting_levels[3] &
                !!rlang::sym(sanitation_facility_jmp_cat) == sanitation_facility_jmp_cat_levels[6] ~ NA_real_,
            # Default
            .default = NA_real_
            ),
        comp_wash_score_hygiene = dplyr::case_when(
            # Camp and Urban are the same
            !!rlang::sym(setting) == setting_levels[1:2] & !!rlang::sym(handwashing_facility_jmp_cat) == handwashing_facility_jmp_cat_levels[1] ~ 3,
            !!rlang::sym(setting) == setting_levels[1:2] & !!rlang::sym(handwashing_facility_jmp_cat) == handwashing_facility_jmp_cat_levels[2] ~ 2,
            !!rlang::sym(setting) == setting_levels[1:2] & !!rlang::sym(handwashing_facility_jmp_cat) == handwashing_facility_jmp_cat_levels[3] ~ 1,
            !!rlang::sym(setting) == setting_levels[1:2] & !!rlang::sym(handwashing_facility_jmp_cat) == handwashing_facility_jmp_cat_levels[4] ~ NA_real_,
            # Rural
            !!rlang::sym(setting) == setting_levels[3] & !!rlang::sym(handwashing_facility_jmp_cat) == handwashing_facility_jmp_cat_levels[1:2] ~ 2,
            !!rlang::sym(setting) == setting_levels[3] & !!rlang::sym(handwashing_facility_jmp_cat) == handwashing_facility_jmp_cat_levels[3] ~ 1,
            !!rlang::sym(setting) == setting_levels[3] & !!rlang::sym(handwashing_facility_jmp_cat) == handwashing_facility_jmp_cat_levels[4] ~ NA_real_,
            .default = NA_real_
        )
    )

    # Compute total score = max
    df <- dplyr::mutate(
        df,
        comp_wash_score = pmax(
            !!!rlang::syms(c("comp_wash_score_water_quantity", "comp_wash_score_water_quality", "comp_wash_score_sanitation", "comp_wash_score_hygiene")),
            na.rm = TRUE
        )
    )

    # Is in need?
    df <- is_in_need(
        df,
        "comp_wash_score",
        "comp_wash_in_need"
    )

    # Is in acute need?
    df <- is_in_acute_need(
        df,
        "comp_wash_score",
        "comp_wash_in_acute_need"
    )

    return(df)

}
