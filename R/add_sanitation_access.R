# ANA
#' 2025 INDICATOR ID: IND143 and 144
#' 2026 METRIC ID: TBD

#' @title Add Physical Sanitation Access Issue
#'
#' @description Computes a binary variable (`wash_sanitation_access_issue_physical_d`) that is 1 if the household reported any physical challenge in accessing sanitation facilities (too far, difficult to use, disability-related barriers or safety concerns), 0 if none were reported, and NA if the response was ambiguous (dnk/pnta/other) or the household has no sanitation facility (`wash_sanitation_facility = 'none'`).
#'
#' @param df A data frame.
#' @param sanitation_access_issue Base name of the select_multiple variable.
#' @param physical Character vector of responses that indicate physical access challenges.
#' @param undefined Character vector of undefined responses (dnk, pnta, other).
#' @param sanitation_facility Column name for the sanitation facility type.
#' @param none Response code for no sanitation facility (open defecation).
#' @param sep Separator for the binary columns.
#'
#' @return A data frame with one additional column:
#'
#' * wash_sanitation_access_issue_physical_d which takes 1 if any physical challenge is reported; 0 if no physical challenge is reported; NA if undefined response or no facility.
#'
#' @family sanitation_access_issue
#' @export
add_sanitation_access_issue_physical <- function(
    df,
    sanitation_access_issue = "wash_sanitation_access_issue",
    physical = c(
        "waterpoints_too_far",
        "waterpoints_difficult_use",
        "disability_no_access_waterpoints",
        "safety_concerns_waterpoints",
        "safety_concerns_travel_waterpoints"
    ),
    undefined = c("dnk", "pnta", "other"),
    sanitation_facility = "wash_sanitation_facility",
    none = "none",
    sep = "/"
) {
    #------ Checks

    # relevant base columns are in the dataset
    if_not_in_stop(df, sanitation_access_issue, "df")
    if_not_in_stop(df, sanitation_facility, "df")

    # columns are in the dataset and are binary
    d_physical <- paste0(sanitation_access_issue, sep, physical)
    d_undefined <- paste0(sanitation_access_issue, sep, undefined)
    are_values_in_set(df, c(d_physical, d_undefined), c(0, 1))

    #------ Compute

    df <- dplyr::mutate(
        df,
        wash_sanitation_access_issue_physical_d = dplyr::case_when(
            .data[[sanitation_facility]] %in% none ~ NA_real_,
            dplyr::if_any(dplyr::all_of(d_undefined), \(x) x == 1) ~ NA_real_,
            dplyr::if_any(dplyr::all_of(d_physical), \(x) x == 1) ~ 1,
            .default = 0
        )
    )

    return(df)
}


#' @rdname add_sanitation_access_issue_physical
#'
#' @title Add Social Sanitation Access Issue Indicator
#'
#' @description Computes a binary variable (`wash_sanitation_access_issue_social_d`)
#' that is 1 if the household reported any social challenge in accessing sanitation facilities (certain groups lacking access or no gender segregation), 0 if none were reported, and NA if the response was ambiguous (dnk/pnta/other) or the household has no sanitation facility (`wash_sanitation_facility = 'none'`).
#'
#' @param social Character vector of responses that indicate social access challenges.
#'
#' @return A data frame with one additional column:
#'
#' * wash_sanitation_access_issue_social_d which takes 1 if any social challenge is reported; 0 if no social challenge is reported; NA if undefined response or no facility.
#'
#' @family sanitation_access_issue
#' @export
add_sanitation_access_issue_social <- function(
    df,
    sanitation_access_issue = "wash_sanitation_access_issue",
    social = c(
        "groups_no_access_waterpoints",
        "not_segregated_gender"
    ),
    undefined = c("dnk", "pnta", "other"),
    sanitation_facility = "wash_sanitation_facility",
    none = "none",
    sep = "/"
) {
    #------ Checks

    # relevant base columns are in the dataset
    if_not_in_stop(df, sanitation_access_issue, "df")
    if_not_in_stop(df, sanitation_facility, "df")

    # columns are in the dataset and are binary
    d_social <- paste0(sanitation_access_issue, sep, social)
    d_undefined <- paste0(sanitation_access_issue, sep, undefined)
    are_values_in_set(df, c(d_social, d_undefined), c(0, 1))

    #------ Compute

    df <- dplyr::mutate(
        df,
        wash_sanitation_access_issue_social_d = dplyr::case_when(
            .data[[sanitation_facility]] %in% none ~ NA_real_,
            dplyr::if_any(dplyr::all_of(d_undefined), \(x) x == 1) ~ NA_real_,
            dplyr::if_any(dplyr::all_of(d_social), \(x) x == 1) ~ 1,
            .default = 0
        )
    )

    return(df)
}
