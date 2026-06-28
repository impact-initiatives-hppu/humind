#' add_fcs
#'
#' @param .dataset Main Dataset
#' @param cutoffs either "normal", or "alternative". The default is set to normal
#' @param fsl_fcs_cereal the name of the variable that indicates the number of days cereals were consumed
#' @param fsl_fcs_legumes the name of the variable that indicates the number of days legumes were consumed
#' @param fsl_fcs_veg the name of the variable that indicates the number of days vegetables were consumed
#' @param fsl_fcs_fruit the name of the variable that indicates the number of days fruits were consumed
#' @param fsl_fcs_meat the name of the variable that indicates the number of days meat/fish were consumed
#' @param fsl_fcs_dairy the name of the variable that indicates the number of days dairy were consumed
#' @param fsl_fcs_sugar the name of the variable that indicates the number of days sugar was consumed
#' @param fsl_fcs_oil the name of the variable that indicates the number of days oil were consumed
#'
#' @return the dataset with fsl_fcs_score and fsl_fcs_cat computed, as well as the 8 weighted food groups
#' @export
#'
#' @examples
#' df1 <- data.frame(
#'   fsl_fcs_cereal = c(1, 2, 3, 2, 5, 6, 7),
#'   fsl_fcs_legumes = c(3, 4, 5, 6, 1, 6, 5),
#'   fsl_fcs_veg = c(3, 2, 1, 6, 5, 4, 3),
#'   fsl_fcs_fruit = c(1, 4, 6, 2, 2, 2, 4),
#'   fsl_fcs_meat = c(5, 4, 3, 2, 7, 4, 5),
#'   fsl_fcs_dairy = c(1, 2, 6, 7, 3, 4, 2),
#'   fsl_fcs_sugar = c(1, 7, 6, 5, 2, 3, 4),
#'   fsl_fcs_oil = c(2, 3, 6, 5, 1, 7, 4)
#' )
#' add_fcs(.dataset = df1,
#'   cutoffs = "normal"
#' )
#'

add_fcs <- function(
  .dataset,
  cutoffs = c("normal", "alternative"),
  fsl_fcs_cereal = "fsl_fcs_cereal",
  fsl_fcs_legumes = "fsl_fcs_legumes",
  fsl_fcs_veg = "fsl_fcs_veg",
  fsl_fcs_fruit = "fsl_fcs_fruit",
  fsl_fcs_meat = "fsl_fcs_meat",
  fsl_fcs_dairy = "fsl_fcs_dairy",
  fsl_fcs_sugar = "fsl_fcs_sugar",
  fsl_fcs_oil = "fsl_fcs_oil"
) {
  ## Throw an error if a dataset wasn't provided as a first argument
  if (!is.data.frame(.dataset)) {
    stop("First argument should be a dataset")
  }

  if (nrow(.dataset) == 0) {
    stop("Dataset is empty")
  }
  if ("fsl_fcs_score" %in% names(.dataset)) {
    warning(
      "There is already a variable called fsl_fcs_score in your dataset, it will be overwritten"
    )
  }

  if ("fsl_fcs_cat" %in% names(.dataset)) {
    warning(
      "There is already a variable called fsl_fcs_cat in your dataset, it will be overwritten"
    )
  }

  fcs_vars <- c(
    fsl_fcs_cereal,
    fsl_fcs_legumes,
    fsl_fcs_dairy,
    fsl_fcs_meat,
    fsl_fcs_veg,
    fsl_fcs_fruit,
    fsl_fcs_oil,
    fsl_fcs_sugar
  )
  ## Test if all columns are in the dataset
  if (!all(fcs_vars %in% names(.dataset))) {
    stop("Missing fcs columns")
  }

  fcs_values <- c(0, 1, 2, 3, 4, 5, 6, 7)
  if (!all(.dataset[[fsl_fcs_cereal]] %in% c(fcs_values, NA))) {
    stop(sprintf(
      "Wrong values in %s: %s ",
      fsl_fcs_cereal,
      paste0(
        unique(.dataset[[fsl_fcs_cereal]][
          !.dataset[[fsl_fcs_cereal]] %in% c(fcs_values, NA)
        ]),
        collapse = "/"
      )
    ))
  }

  if (!all(.dataset[[fsl_fcs_legumes]] %in% c(fcs_values, NA))) {
    stop(sprintf(
      "Wrong values in %s: %s ",
      fsl_fcs_legumes,
      paste0(
        unique(.dataset[[fsl_fcs_legumes]][
          !.dataset[[fsl_fcs_legumes]] %in% c(fcs_values, NA)
        ]),
        collapse = "/"
      )
    ))
  }

  if (!all(.dataset[[fsl_fcs_dairy]] %in% c(fcs_values, NA))) {
    stop(sprintf(
      "Wrong values in %s: %s ",
      fsl_fcs_dairy,
      paste0(
        unique(.dataset[[fsl_fcs_dairy]][
          !.dataset[[fsl_fcs_dairy]] %in% c(fcs_values, NA)
        ]),
        collapse = "/"
      )
    ))
  }

  if (!all(.dataset[[fsl_fcs_meat]] %in% c(fcs_values, NA))) {
    stop(sprintf(
      "Wrong values in %s: %s ",
      fsl_fcs_meat,
      paste0(
        unique(.dataset[[fsl_fcs_meat]][
          !.dataset[[fsl_fcs_meat]] %in% c(fcs_values, NA)
        ]),
        collapse = "/"
      )
    ))
  }

  if (!all(.dataset[[fsl_fcs_veg]] %in% c(fcs_values, NA))) {
    stop(sprintf(
      "Wrong values in %s: %s ",
      fsl_fcs_veg,
      paste0(
        unique(.dataset[[fsl_fcs_veg]][
          !.dataset[[fsl_fcs_veg]] %in% c(fcs_values, NA)
        ]),
        collapse = "/"
      )
    ))
  }

  if (!all(.dataset[[fsl_fcs_fruit]] %in% c(fcs_values, NA))) {
    stop(sprintf(
      "Wrong values in %s: %s ",
      fsl_fcs_fruit,
      paste0(
        unique(.dataset[[fsl_fcs_fruit]][
          !.dataset[[fsl_fcs_fruit]] %in% c(fcs_values, NA)
        ]),
        collapse = "/"
      )
    ))
  }

  if (!all(.dataset[[fsl_fcs_oil]] %in% c(fcs_values, NA))) {
    stop(sprintf(
      "Wrong values in %s: %s ",
      fsl_fcs_oil,
      paste0(
        unique(.dataset[[fsl_fcs_oil]][
          !.dataset[[fsl_fcs_oil]] %in% c(fcs_values, NA)
        ]),
        collapse = "/"
      )
    ))
  }

  if (!all(.dataset[[fsl_fcs_sugar]] %in% c(fcs_values, NA))) {
    stop(sprintf(
      "Wrong values in %s: %s ",
      fsl_fcs_sugar,
      paste0(
        unique(.dataset[[fsl_fcs_sugar]][
          !.dataset[[fsl_fcs_sugar]] %in% c(fcs_values, NA)
        ]),
        collapse = "/"
      )
    ))
  }

  .dataset <- .dataset %>%
    dplyr::mutate_at(dplyr::vars(fcs_vars), as.numeric) %>%
    dplyr::mutate(
      fcs_weight_cereal1 = ifelse(
        is.na(!!rlang::sym(fsl_fcs_cereal)),
        NA,
        !!rlang::sym(fsl_fcs_cereal) * 2
      ),
      fcs_weight_legume2 = ifelse(
        is.na(!!rlang::sym(fsl_fcs_legumes)),
        NA,
        !!rlang::sym(fsl_fcs_legumes) * 3
      ),
      fcs_weight_dairy3 = ifelse(
        is.na(!!rlang::sym(fsl_fcs_dairy)),
        NA,
        !!rlang::sym(fsl_fcs_dairy) * 4
      ),
      fcs_weight_meat4 = ifelse(
        is.na(!!rlang::sym(fsl_fcs_meat)),
        NA,
        !!rlang::sym(fsl_fcs_meat) * 4
      ),
      fcs_weight_veg5 = ifelse(
        is.na(!!rlang::sym(fsl_fcs_veg)),
        NA,
        !!rlang::sym(fsl_fcs_veg) * 1
      ),
      fcs_weight_fruit6 = ifelse(
        is.na(!!rlang::sym(fsl_fcs_fruit)),
        NA,
        !!rlang::sym(fsl_fcs_fruit) * 1
      ),
      fcs_weight_oil7 = ifelse(
        is.na(!!rlang::sym(fsl_fcs_oil)),
        NA,
        !!rlang::sym(fsl_fcs_oil) * 0.5
      ),
      fcs_weight_sugar8 = ifelse(
        is.na(!!rlang::sym(fsl_fcs_sugar)),
        NA,
        !!rlang::sym(fsl_fcs_sugar) * 0.5
      )
    ) %>%
    dplyr::mutate(
      fsl_fcs_score = rowSums(dplyr::across(
        c(
          fcs_weight_cereal1,
          fcs_weight_legume2,
          fcs_weight_dairy3,
          fcs_weight_meat4,
          fcs_weight_veg5,
          fcs_weight_fruit6,
          fcs_weight_oil7,
          fcs_weight_sugar8
        ),
        .fns = as.numeric
      ))
    )
  if (cutoffs == "normal") {
    .dataset <- .dataset %>%
      dplyr::mutate(
        fsl_fcs_cat = dplyr::case_when(
          fsl_fcs_score < 21.5 ~ "Poor",
          fsl_fcs_score <= 35 ~ "Borderline",
          fsl_fcs_score > 35 ~ "Acceptable",
          TRUE ~ NA
        )
      )
  } else if (cutoffs == "alternative") {
    .dataset <- .dataset %>%
      dplyr::mutate(
        fsl_fcs_cat = dplyr::case_when(
          fsl_fcs_score <= 28 ~ "Poor",
          fsl_fcs_score <= 42 ~ "Borderline",
          fsl_fcs_score > 42 ~ "Acceptable",
          TRUE ~ NA
        )
      )
  }
  return(.dataset)
}
