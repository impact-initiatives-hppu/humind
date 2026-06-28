#' Add the household hunger scale to the dataset
#'
#' @param .dataset Main Dataset
#' @param fsl_hhs_nofoodhh The name of the column "In the past 4 weeks (30 days), was there ever no food to eat
#' of any kind in your house because of lack of resources to get food?". It has to be a string.
#' @param fsl_hhs_nofoodhh_freq The name of the column "How often did this happen in the past (4 weeks/30 days)?".
#' It has to be a string.
#' @param fsl_hhs_sleephungry The name of the column "In the past 4 weeks (30 days), did you or any household
#' member go to sleep at night hungry because there was not enough food?". It has to be a string.
#' @param fsl_hhs_sleephungry_freq The name of the column "How often did this happen in the past (4 weeks/30 days)?".
#' It has to be a string.
#' @param fsl_hhs_alldaynight The name of the column "In the past 4 weeks (30 days), did you or any household
#' member go a whole day and night without eating anything at all because there was not enough food?".
#' It has to be a string.
#' @param fsl_hhs_alldaynight_freq The name of the column "How often did this happen in the past (4 weeks/30 days)?".
#' It has to be a string.
#' @param yes_answer Value used for "yes"
#' @param no_answer Value used for the "no"
#' @param rarely_answer Value used for "rarely"
#' @param sometimes_answer Value used for "sometimes"
#' @param often_answer Value used for "often"
#'
#' @return It returns the dataframe with 12 extras columns: recoded hhs questions, score for the 3 sets of questions
#' (from 0 to 2), the HHS score (from 0 to 6), the HHS category and the HHS IPC category
#'
#' @export
#'
#' @examples {
#'   input_data <- data.frame(
#'     fsl_hhs_nofoodhh = c("no", "yes", "no", "no", "no"),
#'     fsl_hhs_nofoodhh_freq = c(NA_character_, "rarely",
#'      NA_character_, NA_character_, NA_character_),
#'     fsl_hhs_sleephungry = c("no", "no", "yes", "no", "no"),
#'     fsl_hhs_sleephungry_freq = c(NA_character_, NA_character_,
#'      "often", NA_character_, NA_character_),
#'     fsl_hhs_alldaynight = c("no", "no", "yes", "yes", "yes"),
#'     fsl_hhs_alldaynight_freq = c(NA_character_, NA_character_,
#'      "often", "rarely", "sometimes")
#'   )
#'
#'   add_hhs(
#'     .dataset = input_data,
#'     fsl_hhs_nofoodhh = "fsl_hhs_nofoodhh",
#'     fsl_hhs_nofoodhh_freq = "fsl_hhs_nofoodhh_freq",
#'     fsl_hhs_sleephungry = "fsl_hhs_sleephungry",
#'     fsl_hhs_sleephungry_freq = "fsl_hhs_sleephungry_freq",
#'     fsl_hhs_alldaynight = "fsl_hhs_alldaynight",
#'     fsl_hhs_alldaynight_freq = "fsl_hhs_alldaynight_freq",
#'     yes_answer = "yes",
#'     no_answer = "no",
#'     rarely_answer = "rarely",
#'     sometimes_answer = "sometimes",
#'     often_answer = "often"
#'   )
#' }

add_hhs <- function(
  .dataset,
  fsl_hhs_nofoodhh = "fsl_hhs_nofoodhh",
  fsl_hhs_nofoodhh_freq = "fsl_hhs_nofoodhh_freq",
  fsl_hhs_sleephungry = "fsl_hhs_sleephungry",
  fsl_hhs_sleephungry_freq = "fsl_hhs_sleephungry_freq",
  fsl_hhs_alldaynight = "fsl_hhs_alldaynight",
  fsl_hhs_alldaynight_freq = "fsl_hhs_alldaynight_freq",
  yes_answer = "yes",
  no_answer = "no",
  rarely_answer = "rarely",
  sometimes_answer = "sometimes",
  often_answer = "often"
) {
  ## Throw an error if a dataset wasn't provided as a first argument
  if (!is.data.frame(.dataset)) {
    stop("First argument should be a dataset")
  }

  ## Throw an error if the dataset is empty
  if (nrow(.dataset) == 0) {
    stop("Dataset is empty")
  }
  hhs_vars <- c(
    fsl_hhs_nofoodhh,
    fsl_hhs_nofoodhh_freq,
    fsl_hhs_sleephungry,
    fsl_hhs_sleephungry_freq,
    fsl_hhs_alldaynight,
    fsl_hhs_alldaynight_freq
  )
  ## Test if all columns are in the dataset
  if (!all(hhs_vars %in% names(.dataset))) {
    stop("Missing hhs columns")
  }

  cat_yn_values <- c(yes_answer, no_answer)
  ## Throw an error in case wrong/unexpected values are found in hhs_nofoodhh
  if (!all(.dataset[[fsl_hhs_nofoodhh]] %in% c(cat_yn_values, NA))) {
    stop(sprintf(
      "Wrong values in %s: %s ",
      fsl_hhs_nofoodhh,
      paste0(
        unique(.dataset[[fsl_hhs_nofoodhh]][
          !.dataset[[fsl_hhs_nofoodhh]] %in% c(cat_yn_values, NA)
        ]),
        collapse = "/"
      )
    ))
  }

  ## Throw an error in case wrong/unexpected values are found in hhs_sleephungry
  if (!all(.dataset[[fsl_hhs_sleephungry]] %in% c(cat_yn_values, NA))) {
    stop(sprintf(
      "Wrong values in %s: %s ",
      fsl_hhs_sleephungry,
      paste0(
        unique(.dataset[[fsl_hhs_sleephungry]][
          !.dataset[[fsl_hhs_sleephungry]] %in% c(cat_yn_values, NA)
        ]),
        collapse = "/"
      )
    ))
  }

  ## Throw an error in case wrong/unexpected values are found in hhs_alldaynight
  if (!all(.dataset[[fsl_hhs_alldaynight]] %in% c(cat_yn_values, NA))) {
    stop(sprintf(
      "Wrong values in %s: %s ",
      fsl_hhs_alldaynight,
      paste0(
        unique(.dataset[[fsl_hhs_alldaynight]][
          !.dataset[[fsl_hhs_alldaynight]] %in% c(cat_yn_values, NA)
        ]),
        collapse = "/"
      )
    ))
  }

  cat_values <- c(rarely_answer, sometimes_answer, often_answer)

  ## Throw an error in case wrong/unexpected values are found in hhs_nofoodhh_freq
  if (!all(.dataset[[fsl_hhs_nofoodhh_freq]] %in% c(cat_values, NA))) {
    stop(sprintf(
      "Wrong values in %s: %s ",
      fsl_hhs_nofoodhh_freq,
      paste0(
        unique(.dataset[[fsl_hhs_nofoodhh_freq]][
          !.dataset[[fsl_hhs_nofoodhh_freq]] %in% c(cat_values, NA)
        ]),
        collapse = "/"
      )
    ))
  }

  ## Throw an error in case wrong/unexpected values are found in hhs_sleephungry_freq
  if (!all(.dataset[[fsl_hhs_sleephungry_freq]] %in% c(cat_values, NA))) {
    stop(sprintf(
      "Wrong values in %s: %s ",
      fsl_hhs_sleephungry_freq,
      paste0(
        unique(.dataset[[fsl_hhs_sleephungry_freq]][
          !.dataset[[fsl_hhs_sleephungry_freq]] %in% c(cat_values, NA)
        ]),
        collapse = "/"
      )
    ))
  }

  ## Throw an error in case wrong/unexpected values are found in hhs_alldaynight_freq
  if (!all(.dataset[[fsl_hhs_alldaynight_freq]] %in% c(cat_values, NA))) {
    stop(sprintf(
      "Wrong values in %s: %s ",
      fsl_hhs_alldaynight_freq,
      paste0(
        unique(.dataset[[fsl_hhs_alldaynight_freq]][
          !.dataset[[fsl_hhs_alldaynight_freq]] %in% c(cat_values, NA)
        ]),
        collapse = "/"
      )
    ))
  }

  .dataset_with_calculation <- .dataset %>%
    dplyr::mutate_at(
      c(fsl_hhs_nofoodhh, fsl_hhs_sleephungry, fsl_hhs_alldaynight),
      ~ dplyr::case_when(.x == yes_answer ~ 1, .x == no_answer ~ 0)
    ) %>%
    dplyr::mutate_at(
      c(
        fsl_hhs_nofoodhh_freq,
        fsl_hhs_sleephungry_freq,
        fsl_hhs_alldaynight_freq
      ),
      ~ dplyr::case_when(
        .x %in% c(rarely_answer, sometimes_answer) ~ 1,
        .x == often_answer ~ 2,
        TRUE ~ 0
      )
    ) %>%
    dplyr::rowwise() %>%
    dplyr::mutate(
      fsl_hhs_comp1 = !!rlang::sym(fsl_hhs_nofoodhh) *
        !!rlang::sym(fsl_hhs_nofoodhh_freq),
      fsl_hhs_comp2 = !!rlang::sym(fsl_hhs_sleephungry) *
        !!rlang::sym(fsl_hhs_sleephungry_freq),
      fsl_hhs_comp3 = !!rlang::sym(fsl_hhs_alldaynight) *
        !!rlang::sym(fsl_hhs_alldaynight_freq)
    ) %>%
    dplyr::ungroup() %>%
    dplyr::mutate(
      fsl_hhs_score = rowSums(.[grep("^fsl_hhs_comp\\d$", names(.))])
    ) %>%
    dplyr::mutate(
      fsl_hhs_cat_ipc = dplyr::case_when(
        fsl_hhs_score == 0 ~ "None",
        fsl_hhs_score == 1 ~ "Little",
        fsl_hhs_score <= 3 ~ "Moderate",
        fsl_hhs_score == 4 ~ "Severe",
        fsl_hhs_score <= 6 ~ "Very Severe"
      ),
      fsl_hhs_cat = dplyr::case_when(
        fsl_hhs_score <= 1 ~ "Little to No",
        fsl_hhs_score <= 3 ~ "Moderate",
        fsl_hhs_score <= 6 ~ "Severe",
        TRUE ~ NA
      )
    )
  columns_to_export <- .dataset_with_calculation %>%
    dplyr::rename_at(
      c(
        fsl_hhs_nofoodhh,
        fsl_hhs_nofoodhh_freq,
        fsl_hhs_sleephungry,
        fsl_hhs_sleephungry_freq,
        fsl_hhs_alldaynight,
        fsl_hhs_alldaynight_freq
      ),
      ~ paste0(.x, "_recoded")
    ) %>%
    dplyr::select(
      paste0(fsl_hhs_nofoodhh, "_recoded"),
      paste0(fsl_hhs_nofoodhh_freq, "_recoded"),
      paste0(fsl_hhs_sleephungry, "_recoded"),
      paste0(fsl_hhs_sleephungry_freq, "_recoded"),
      paste0(fsl_hhs_alldaynight, "_recoded"),
      paste0(fsl_hhs_alldaynight_freq, "_recoded"),
      fsl_hhs_comp1,
      fsl_hhs_comp2,
      fsl_hhs_comp3,
      fsl_hhs_score,
      fsl_hhs_cat_ipc,
      fsl_hhs_cat
    )

  for (i in names(columns_to_export)) {
    if (i %in% names(.dataset)) {
      .dataset <- .dataset %>%
        dplyr::select(-i)
    }
  }

  .dataset <- .dataset %>%
    cbind(columns_to_export)

  return(.dataset)
}
