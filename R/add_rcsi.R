#' Add indicator for reduced Household CSI Score(rcsi)
#'
#' @param .dataset Main Dataset
#' @param fsl_rcsi_lessquality Column representing question- During the last 7 days, were there days (and, if so, how many) when your household had to rely on less preferred and less expensive food to cope with a lack of food or money to buy it?
#' @param fsl_rcsi_borrow   Column representing question- During the last 7 days, were there days (and, if so, how many) when your household had to borrow food or rely on help from a relative or friend to cope with a lack of food or money to buy it?
#' @param fsl_rcsi_mealsize Column representing question- During the last 7 days, were there days (and, if so, how many) when your household had to limit portion size of meals at meal times to cope with a lack of food or money to buy it?
#' @param fsl_rcsi_mealadult Column representing question- During the last 7 days, were there days (and, if so, how many) when your household had to restrict consumption by adults in order for small children to eat to cope with a lack of food or money to buy it?
#' @param fsl_rcsi_mealnb Column representing question - During the last 7 days, were there days (and, if so, how many) when your household had to reduce number of meals eaten in a day to cope with a lack of food or money to buy it?
#' @return
#' A dataset with one additional column.
#' @export
#' @importFrom rlang :=
#' @examples
#' test_data <- data.frame(
#'   fsl_rcsi_lessquality = c(1, 2, 3, 1),
#'   fsl_rcsi_borrow = c(0, 0, 3, 0),
#'   fsl_rcsi_mealsize = c(4, 2, 6, 1),
#'   fsl_rcsi_mealadult = c(4, 3, 5, 0),
#'   fsl_rcsi_mealnb = c(2, 5, NA_integer_, 1)
#' )
#' add_rcsi(test_data)

add_rcsi <- function(
  .dataset,
  fsl_rcsi_lessquality = "fsl_rcsi_lessquality",
  fsl_rcsi_borrow = "fsl_rcsi_borrow",
  fsl_rcsi_mealsize = "fsl_rcsi_mealsize",
  fsl_rcsi_mealadult = "fsl_rcsi_mealadult",
  fsl_rcsi_mealnb = "fsl_rcsi_mealnb"
) {
  if (!is.data.frame(.dataset)) {
    stop("First argument should be a dataset")
  }

  if (nrow(.dataset) == 0) {
    stop("Dataset is empty")
  }
  rcsi_vars <- c(
    fsl_rcsi_lessquality,
    fsl_rcsi_borrow,
    fsl_rcsi_mealsize,
    fsl_rcsi_mealadult,
    fsl_rcsi_mealnb
  )

  ## Test if all columns are in the dataset
  if (!all(rcsi_vars %in% names(.dataset))) {
    stop("Missing rcsi columns")
  }

  if ("fsl_rcsi_score" %in% names(.dataset)) {
    warning(
      "There is already a variable called rcsi_score in your dataset, it will be overwritten"
    )
  }

  if ("fsl_rcsi_cat" %in% names(.dataset)) {
    warning(
      "There is already a variable called rcsi_cat in your dataset, it will be overwritten"
    )
  }
  rcsi_values <- c(0, 1, 2, 3, 4, 5, 6, 7)

  if (!all(.dataset[[fsl_rcsi_lessquality]] %in% c(rcsi_values, NA))) {
    stop(sprintf(
      "Wrong values in %s: %s ",
      fsl_rcsi_lessquality,
      paste0(
        unique(.dataset[[fsl_rcsi_lessquality]][
          !.dataset[[fsl_rcsi_lessquality]] %in% c(rcsi_values, NA)
        ]),
        collapse = "/"
      )
    ))
  }

  if (!all(.dataset[[fsl_rcsi_borrow]] %in% c(rcsi_values, NA))) {
    stop(sprintf(
      "Wrong values in %s: %s ",
      fsl_rcsi_borrow,
      paste0(
        unique(.dataset[[fsl_rcsi_borrow]][
          !.dataset[[fsl_rcsi_borrow]] %in% c(rcsi_values, NA)
        ]),
        collapse = "/"
      )
    ))
  }

  if (!all(.dataset[[fsl_rcsi_mealsize]] %in% c(rcsi_values, NA))) {
    stop(sprintf(
      "Wrong values in %s: %s ",
      fsl_rcsi_mealsize,
      paste0(
        unique(.dataset[[fsl_rcsi_mealsize]][
          !.dataset[[fsl_rcsi_mealsize]] %in% c(rcsi_values, NA)
        ]),
        collapse = "/"
      )
    ))
  }

  if (!all(.dataset[[fsl_rcsi_mealadult]] %in% c(rcsi_values, NA))) {
    stop(sprintf(
      "Wrong values in %s: %s ",
      fsl_rcsi_mealadult,
      paste0(
        unique(.dataset[[fsl_rcsi_mealadult]][
          !.dataset[[fsl_rcsi_mealadult]] %in% c(rcsi_values, NA)
        ]),
        collapse = "/"
      )
    ))
  }

  if (!all(.dataset[[fsl_rcsi_mealnb]] %in% c(rcsi_values, NA))) {
    stop(sprintf(
      "Wrong values in %s: %s ",
      fsl_rcsi_mealnb,
      paste0(
        unique(.dataset[[fsl_rcsi_mealnb]][
          !.dataset[[fsl_rcsi_mealnb]] %in% c(rcsi_values, NA)
        ]),
        collapse = "/"
      )
    ))
  }

  rcs_columns <- c(
    fsl_rcsi_lessquality,
    fsl_rcsi_borrow,
    fsl_rcsi_mealsize,
    fsl_rcsi_mealadult,
    fsl_rcsi_mealnb
  )

  .dataset <- .dataset %>%
    dplyr::mutate_at(dplyr::vars(rcs_columns), as.numeric) %>%
    dplyr::mutate(
      rcsi_lessquality_weighted = ifelse(
        is.na(!!rlang::sym(fsl_rcsi_lessquality)),
        NA,
        !!rlang::sym(fsl_rcsi_lessquality) * 1
      ),
      rcsi_borrow_weighted = ifelse(
        is.na(!!rlang::sym(fsl_rcsi_borrow)),
        NA,
        !!rlang::sym(fsl_rcsi_borrow) * 2
      ),
      rcsi_mealsize_weighted = ifelse(
        is.na(!!rlang::sym(fsl_rcsi_mealsize)),
        NA,
        !!rlang::sym(fsl_rcsi_mealsize) * 1
      ),
      rcsi_mealadult_weighted = ifelse(
        is.na(!!rlang::sym(fsl_rcsi_mealadult)),
        NA,
        !!rlang::sym(fsl_rcsi_mealadult) * 3
      ),
      rcsi_mealnb_weighted = ifelse(
        is.na(!!rlang::sym(fsl_rcsi_mealnb)),
        NA,
        !!rlang::sym(fsl_rcsi_mealnb) * 1
      ),
      fsl_rcsi_score = rowSums(dplyr::across(
        c(
          rcsi_lessquality_weighted,
          rcsi_borrow_weighted,
          rcsi_mealsize_weighted,
          rcsi_mealadult_weighted,
          rcsi_mealnb_weighted
        ),
        .fns = as.numeric
      )),
      fsl_rcsi_cat = dplyr::case_when(
        fsl_rcsi_score <= 3 ~ "No to Low",
        fsl_rcsi_score <= 18 ~ "Medium",
        fsl_rcsi_score > 18 ~ "High",
        TRUE ~ NA
      )
    )
  return(.dataset)
}
