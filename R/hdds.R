#' HHDS - Household Dietary Diversity Score (standalone version)
#' 
#' @param df A data frame
#' @param hdds_cereal Cereals and grain component column
#' @param hdds_roots Roots and tubers component column
#' @param hdds_legumes Legumes, pulses, and nuts component column
#' @param hdds_dairy Dairy, milk, and others component column
#' @param hdds_meat Meat component column
#' @param hdds_fish Fish and shellfish component column
#' @param hdds_egg Eggs component column
#' @param hdds_veg Vegetables component column
#' @param hdds_fruits Fruits component column
#' @param hdds_oil Oil component column
#' @param hdds_sugar Sugar component column
#' @param hdds_spices Spices component column
#' @param level_codes Character vector of responses codes, including first in the following order: "Yes", "No", "Do not know", "Prefer not to answer", e.g., c("yes", "no", "do_not_know", "prefer_not_to_answer").
#'
#' @return Thirteen new columns: each component dummy variable if "Yes" (hdds_*_d) and HDDS score (hdds_score).
#' 
#' @export
hdds <- function(df,
                hdds_cereal = "hdds_ceral",
                hdds_roots = "hdds_roots",
                hdds_legumes = "hdds_legumes",
                hdds_dairy = "hdds_dairy",
                hdds_meat = "hdds_meat",
                hdds_fish = "hdds_fish",
                hdds_egg = "hdds_egg",
                hdds_veg = "hdds_veg",
                hdds_fruits = "hdds_fruits",
                hdds_oil = "hdds_oil",
                hdds_sugar = "hdds_sugar",
                hdds_spices = "hdds_spices",
                level_codes = c("yes", "no" ,"do_not_know", "prefer_not_to_answer")){

    #------ Enquo and get character names
    hdds_cols <- rlang::enquos(hdds_cereal, hdds_roots, hdds_legumes, hdds_dairy, hdds_meat, hdds_fish, hdds_egg, hdds_veg, hdds_fruits, hdds_oil, hdds_sugar, hdds_spices)
    hdds_cols <- purrr::map_chr(hdds_cols, rlang::as_name)

    #------ Check values ranges and numeric type
    are_values_in_set(df, hdds_cols, level_codes)

    #----- Add dummy columns
    df <- dplyr::mutate(
        df,
        dplyr::across(
            .cols = hdds_cols,
            .fns = \(x) ifelse(x == level_codes[1], 1, 0),
            .names = "{.col}_d"))

    #------ HDDS score
    df <- dplyr::mutate(
        df,
        hdds_score = rowSums(
            dplyr::across(
                dplyr::all_of(hdds_cols_d)
            ),
            na.rm = FALSE
        )
    
    #------ HDDS categories
    df <- dplyr::mutate(
        hdds_cat = dplyr::case_when(
            hdds_score <= 2 ~ "0-2 food groups (phase 4 to 5)",
            hdds_score <= 4 ~ "3-4 food groups (phase 3)",
            hdds_score <= 5 ~ "5 food groups (phase 2)",
            hdds_score <= 12 ~ "6-12 food groups (phase 1)",
            TRUE ~ NA_character_
        )
    )

    return(df)

}