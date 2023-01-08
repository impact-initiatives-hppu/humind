#' @title FCS - Food Consumption Score
#'
#' @param df A data frame
#' @param fcs_cereal Cereals component column
#' @param fcs_legumes Legumes component column
#' @param fcs_dairy Dairy component column
#' @param fcs_meat Meat component column
#' @param fcs_veg Vegetables component column
#' @param fcs_fruit Fruit component column
#' @param fcs_oil Oil component column
#' @param fcs_sugar Sugar component column
#' @param cat Cut-offs categories, either "normal" (21.5/35) or "alternate" (28/42)
#'
#' @return Ten new columns: each component weight (fcs_w_), the score (fcs_score) and category (fcs_cat).
#'
#' @export
fcs <- function(df,
                fcs_cereal = "fcs_cereal",
                fcs_legumes = "fcs_legumes",
                fcs_dairy = "fcs_dairy",
                fcs_meat = "fcs_meat",
                fcs_veg = "fcs_veg",
                fcs_fruit = "fcs_fruit",
                fcs_oil = "fcs_oil",
                fcs_sugar = "fcs_sugar",
                cat = "normal") {

  #------ Check if category is either normal or alternate
  if (!(cat %in% c("normal", "alternate"))) {
    rlang::abort(glue::glue("`cat` must be one of: 'normal' or 'alternate', not {cat}."))
  }

  #------ Enquo and get character names
  fcs_cols <- rlang::enquos(fcs_cereal, fcs_legumes, fcs_dairy, fcs_meat, fcs_veg, fcs_fruit, fcs_oil, fcs_sugar)
  fcs_cols <- purrr::map_chr(fcs_cols, rlang::as_name)

  #------ Check values ranges and numeric type
  are_values_in_set(df, fcs_cols, 0:7)

  #------ Prepare vector of weighting values
  fcs_w_cols <- c("fcs_w_cereal", "fcs_w_legumes", "fcs_w_dairy", "fcs_w_meat", "fcs_w_veg", "fcs_w_fruit", "fcs_w_oil", "fcs_w_sugar")

  #------ Add weighting columns
  df <- dplyr::mutate(
    df,
    fcs_w_cereal = {{ fcs_cereal }} * 2,
    fcs_w_legumes = {{ fcs_legumes }} * 3,
    fcs_w_dairy = {{ fcs_dairy }} * 4,
    fcs_w_meat = {{ fcs_meat }} * 4,
    fcs_w_veg = {{ fcs_veg }} * 1,
    fcs_w_fruit = {{ fcs_fruit }} * 1,
    fcs_w_oil = {{ fcs_oil }} * 0.5,
    fcs_w_sugar = {{ fcs_sugar }} * 0.5
  )

  #------  FCS score
  df <- dplyr::mutate(
    df,
    fcs_score = rowSums(
      dplyr::across(
        dplyr::all_of(fcs_w_cols)
      ),
      na.rm = FALSE
    )
  )

  #------ FCS category
  if (cat == "normal") {
    df <- dplyr::mutate(
      df,
      fcs_cat = dplyr::case_when(
        fcs_score <= 21 ~ "Poor",
        fcs_score <= 35 ~ "Borderline",
        fcs_score <= 200 ~ "Acceptable",
        TRUE ~ NA_character_
      )
    )
  } else {
    df <- dplyr::mutate(
      df,
      fcs_cat = dplyr::case_when(
        fcs_score <= 28 ~ "Poor",
        fcs_score <= 42 ~ "Borderline",
        fcs_score <= 200 ~ "Acceptable",
        TRUE ~ NA_character_
      )
    )
  }

  return(df)
}
